import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_background.dart';
import '../../../../shared/widgets/app_entrance.dart';
import 'auth_brand_lockup.dart';

/// Kerangka bersama seluruh halaman autentikasi.
///
/// Menangani latar, AppBar transparan, safe area, padding responsif, scroll,
/// dan tata letak dua kolom pada layar lebar. Halaman hanya mengisi konten.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.wideChild,
    this.panel,
    this.showAppBar = true,
    this.showBack = true,
    this.onBack,
    this.maxWidth = AppLayout.authFormMaxWidth,
    this.verticalPadding,
    this.centerVertically = true,
  });

  final Widget child;

  /// Konten alternatif saat tata letak dua kolom aktif. Jika null, [child]
  /// dipakai baik pada mode compact maupun wide.
  final Widget? wideChild;

  /// Panel brand di kolom kiri. Panel hanya tampil bila lebarnya mencukupi.
  final Widget? panel;

  final bool showAppBar;
  final bool showBack;
  final VoidCallback? onBack;
  final double maxWidth;
  final double? verticalPadding;
  final bool centerVertically;

  @override
  Widget build(BuildContext context) {
    return AppPageBackground(
      child: LayoutBuilder(
        builder: (context, page) {
          // Pada tata letak dua kolom, panel brand sudah menampilkan lockup
          // besar. Menyembunyikan wordmark di AppBar mencegah pengulangan yang
          // sama persis dalam satu layar.
          final hasPanel =
              panel != null && page.maxWidth >= AppLayout.authWideBreakpoint;

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: showAppBar
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: AppElevation.none,
                    scrolledUnderElevation: AppElevation.none,
                    automaticallyImplyLeading: false,
                    leading: showBack
                        ? IconButton(
                            tooltip: 'Kembali',
                            onPressed:
                                onBack ??
                                () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          )
                        : null,
                    title: hasPanel ? null : const AuthBrandLockup(),
                    titleSpacing: showBack ? 0 : AppSpacing.screen,
                    toolbarHeight: 64,
                  )
                : null,
            body: SafeArea(
              top: !showAppBar,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = switch (constraints.maxWidth) {
                    < 600 => AppSpacing.screen,
                    < AppLayout.authWideBreakpoint => AppSpacing.xl,
                    _ => AppSpacing.xxl,
                  };
                  final resolvedVerticalPadding =
                      verticalPadding ??
                      (constraints.maxHeight < AppLayout.authShortViewport
                          ? AppSpacing.lg
                          : AppSpacing.xxl);
                  final isWide =
                      panel != null &&
                      constraints.maxWidth >= AppLayout.authWideBreakpoint;

                  final content = isWide
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppLayout.authWideMaxWidth,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: panel!),
                              const SizedBox(width: AppSpacing.xxl),
                              Expanded(
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: maxWidth,
                                    ),
                                    child: wideChild ?? child,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: child,
                        );

                  final body = AppEntrance(child: content);

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      resolvedVerticalPadding,
                      horizontalPadding,
                      resolvedVerticalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight -
                                resolvedVerticalPadding * 2)
                            .clamp(0.0, double.infinity),
                      ),
                      child: centerVertically
                          ? Center(child: body)
                          : Align(
                              alignment: Alignment.topCenter,
                              child: body,
                            ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
