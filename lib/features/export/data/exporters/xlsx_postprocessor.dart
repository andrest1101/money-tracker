import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Menambahkan fitur worksheet yang belum didukung oleh excel_community.
///
/// `excel_community 1.0.10` (satu-satunya versi yang kompatibel dengan Dart
/// SDK proyek ini) belum menyediakan freeze pane dan filter otomatis. Keduanya
/// ditulis langsung ke XML sebelum file dibagikan.
class XlsxPostprocessor {
  const XlsxPostprocessor();

  Uint8List freezePanesAndAutofilter(
    Uint8List bytes, {
    required String sheetName,
    required int freezeRows,
    required String autoFilterRef,
  }) {
    return _processSheet(
      bytes,
      sheetName: sheetName,
      mutate: (xml) {
        var updated = _freezeRows(xml, freezeRows);
        updated = _insertAfterSheetData(
          updated,
          '<autoFilter ref="$autoFilterRef"/>',
        );
        return updated;
      },
    );
  }

  Uint8List applyRingkasanPageSetup(
    Uint8List bytes, {
    required String sheetName,
  }) {
    return _processSheet(
      bytes,
      sheetName: sheetName,
      mutate: _applyPrintPage,
    );
  }

  Uint8List _processSheet(
    Uint8List bytes, {
    required String sheetName,
    required String Function(String xml) mutate,
  }) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final workbookFile = archive.find('xl/workbook.xml');
    final relsFile = archive.find('xl/_rels/workbook.xml.rels');
    if (workbookFile == null || relsFile == null) return bytes;

    final sheetPath = _worksheetPath(
      utf8.decode(workbookFile.content),
      utf8.decode(relsFile.content),
      sheetName,
    );
    if (sheetPath.isEmpty) return bytes;

    final sheetFile = archive.find(sheetPath);
    if (sheetFile == null) return bytes;

    final updatedXml = mutate(utf8.decode(sheetFile.content));
    final updatedBytes = utf8.encode(updatedXml);
    archive.add(
      ArchiveFile(sheetPath, updatedBytes.length, updatedBytes),
    );

    return ZipEncoder().encodeBytes(archive);
  }

  String _worksheetPath(
    String workbookXml,
    String relsXml,
    String sheetName,
  ) {
    final sheetTag = _firstTagMatching(
      workbookXml,
      'sheet',
      (tag) => _attribute(tag, 'name') == sheetName,
    );
    if (sheetTag == null) return '';

    final relationId =
        _attribute(sheetTag, 'r:id') ?? _attribute(sheetTag, 'id');
    if (relationId == null) return '';

    final relationTag = _firstTagMatching(
      relsXml,
      'Relationship',
      (tag) => _attribute(tag, 'Id') == relationId,
    );
    final target = relationTag == null ? null : _attribute(relationTag, 'Target');
    if (target == null || target.isEmpty) return '';

    final normalized = target.replaceAll(r'\', '/');
    if (normalized.startsWith('/')) return normalized.substring(1);
    if (!normalized.startsWith('xl/')) return 'xl/$normalized';
    return normalized;
  }

  String? _firstTagMatching(
    String xml,
    String tagName,
    bool Function(String tag) matches,
  ) {
    final pattern = RegExp('<$tagName\\b[^>]*>');
    for (final match in pattern.allMatches(xml)) {
      final tag = match.group(0);
      if (tag != null && matches(tag)) return tag;
    }
    return null;
  }

  String? _attribute(String tag, String name) {
    final pattern = RegExp(
      '${RegExp.escape(name)}="([^"]*)"',
    );
    return pattern.firstMatch(tag)?.group(1);
  }

  String _freezeRows(String xml, int freezeRows) {
    final topLeft = 'A${freezeRows + 1}';
    final pane =
        '<pane ySplit="$freezeRows" topLeftCell="$topLeft" '
        'activePane="bottomLeft" state="frozen"/>'
        '<selection pane="bottomLeft" activeCell="$topLeft" '
        'sqref="$topLeft"/>';

    final selfClosing = RegExp(r'<sheetView\b([^>]*)/>');
    if (selfClosing.hasMatch(xml)) {
      return xml.replaceFirstMapped(
        selfClosing,
        (match) => '<sheetView${_sheetViewAttributes(match.group(1))}>'
            '$pane</sheetView>',
      );
    }

    final withChildren = RegExp(
      r'<sheetView\b([^>]*)>.*?</sheetView>',
      dotAll: true,
    );
    if (withChildren.hasMatch(xml)) {
      return xml.replaceFirstMapped(
        withChildren,
        (match) =>
            '<sheetView${_sheetViewAttributes(match.group(1))}>'
            '$pane</sheetView>',
      );
    }

    final sheetViews =
        '<sheetViews><sheetView workbookViewId="0" tabSelected="1">'
        '$pane</sheetView></sheetViews>';
    for (final anchor in [
      '<sheetFormatPr',
      '<cols',
      '<sheetData',
    ]) {
      if (xml.contains(anchor)) {
        return xml.replaceFirst(anchor, '$sheetViews$anchor');
      }
    }
    return xml;
  }

  String _sheetViewAttributes(String? raw) {
    var attributes = raw?.trim() ?? '';
    attributes = attributes.replaceAll(
      RegExp(r'\s+tabSelected="[^"]*"'),
      '',
    );
    attributes = attributes.replaceAll(
      RegExp(r'tabSelected="[^"]*"'),
      '',
    );
    if (!attributes.contains('workbookViewId=')) {
      attributes = 'workbookViewId="0" $attributes';
    }
    return ' ${attributes.trim()} tabSelected="1"';
  }

  String _insertAfterSheetData(String xml, String insertion) {
    if (xml.contains(insertion)) return xml;

    const closingTag = '</sheetData>';
    final closingIndex = xml.indexOf(closingTag);
    if (closingIndex >= 0) {
      final insertionIndex = closingIndex + closingTag.length;
      return xml.replaceRange(
        insertionIndex,
        insertionIndex,
        insertion,
      );
    }

    final selfClosing = RegExp(r'<sheetData\b[^>]*/>');
    return xml.replaceFirstMapped(
      selfClosing,
      (match) => '${match.group(0)}$insertion',
    );
  }

  String _applyPrintPage(String xml) {
    const sheetPr = '<sheetPr><pageSetUpPr fitToPage="1"/></sheetPr>';

    var updated = xml;
    if (!updated.contains('<sheetPr')) {
      if (updated.contains('<dimension')) {
        updated = updated.replaceFirst('<dimension', '$sheetPr<dimension');
      } else {
        updated = '$sheetPr$updated';
      }
    } else if (!updated.contains('pageSetUpPr')) {
      final selfClosing = RegExp(r'<sheetPr\b([^>]*)/>');
      if (selfClosing.hasMatch(updated)) {
        updated = updated.replaceFirstMapped(
          selfClosing,
          (match) => '<sheetPr${match.group(1)}>'
              '<pageSetUpPr fitToPage="1"/>'
              '</sheetPr>',
        );
      } else {
        updated = updated.replaceFirstMapped(
          RegExp(r'<sheetPr\b[^>]*>'),
          (match) => '${match.group(0)}<pageSetUpPr fitToPage="1"/>',
        );
      }
    }

    const pageSetup =
        '<pageSetup paperSize="9" orientation="portrait" '
        'fitToWidth="1" fitToHeight="1"/>';
    if (updated.contains('<pageSetup')) {
      updated = updated.replaceFirstMapped(
        RegExp(r'<pageSetup\b[^>]*/>'),
        (match) => pageSetup,
      );
      return updated;
    }

    final pageMargins = RegExp(r'<pageMargins\b[^>]*/>');
    if (pageMargins.hasMatch(updated)) {
      return updated.replaceFirstMapped(
        pageMargins,
        (match) => '${match.group(0)}$pageSetup',
      );
    }

    return updated.replaceFirst(
      '</worksheet>',
      '$pageSetup</worksheet>',
    );
  }
}
