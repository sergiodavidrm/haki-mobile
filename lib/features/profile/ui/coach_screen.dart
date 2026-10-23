import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/coach_profile_dto.dart';
import '../../../l10n/l10n.dart';

// Tu coach (mockup "Tu coach"): iniciales, nombre, años de experiencia, bio y
// certificaciones (las carga el coach en el web) + botón al Chat. Sale de
// /auth/me, así que funciona offline con la caché.
class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final me = ref.watch(authMeProvider).value;
    final coach = me?.coach;
    final name = coach?.fullName ?? me?.coachName ?? l.yourCoach;
    final firstName = name.trim().split(RegExp(r'\s+')).first;
    final years = coach?.experienceYears(DateTime.now());
    final bio = coach?.bio?.trim() ?? '';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            BackHeader(title: l.yourCoach, titleSize: 22),
            const SizedBox(height: 12),
            Column(
              children: [
                UserAvatar(name: name, size: 88, highlighted: true),
                const SizedBox(height: 10),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                  ),
                ),
                if (years != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.goldSurface,
                      border: Border.all(color: c.goldBorder),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 15, color: c.goldBright),
                        const SizedBox(width: 6),
                        Text(
                          l.coachExperience(years),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.goldBright,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 22),
            if (coach == null || coach.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l.coachProfileEmpty(firstName),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: c.textMuted,
                  ),
                ),
              ),
            if (bio.isNotEmpty) ...[
              SectionLabel(l.coachAbout),
              const SizedBox(height: 8),
              Text(
                bio,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
            ],
            if (coach != null && coach.certifications.isNotEmpty) ...[
              SectionLabel(l.coachCertifications),
              const SizedBox(height: 8),
              for (final cert in coach.certifications)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CertificationCard(cert: cert),
                ),
              const SizedBox(height: 14),
            ],
            FilledButton.icon(
              onPressed: () => context.go(Routes.chat),
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: Text(l.coachWrite(firstName)),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  const _CertificationCard({required this.cert});

  final CoachCertificationDto cert;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sub = cert.subtitle;
    return HakiCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.workspace_premium_outlined, size: 20, color: c.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: c.text,
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(sub, style: TextStyle(fontSize: 12, color: c.textMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
