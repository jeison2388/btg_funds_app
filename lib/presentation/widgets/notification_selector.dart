import 'package:flutter/material.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';

class NotificationSelector extends FormField<NotificationMethod> {
  NotificationSelector({
    super.key,
    super.initialValue,
    required ValueChanged<NotificationMethod?> onChanged,
    super.validator,
    this.subtitle,
  }) : super(
          builder: (FormFieldState<NotificationMethod> fieldState) {
            final theme = Theme.of(fieldState.context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Método de notificación',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: NotificationMethod.values.map((method) {
                    final isSelected = fieldState.value == method;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                              method == NotificationMethod.email ? 8.0 : 0.0,
                          left: method == NotificationMethod.sms ? 8.0 : 0.0,
                        ),
                        child: _NotificationOption(
                          method: method,
                          isSelected: isSelected,
                          hasError: fieldState.hasError,
                          onTap: () {
                            fieldState.didChange(method);
                            onChanged(method);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (fieldState.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    fieldState.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        );

  final String? subtitle;
}

class _NotificationOption extends StatelessWidget {
  final NotificationMethod method;
  final bool isSelected;
  final bool hasError;
  final VoidCallback onTap;

  const _NotificationOption({
    required this.method,
    required this.isSelected,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final borderColor = hasError && !isSelected
        ? theme.colorScheme.error
        : isSelected
            ? primary
            : theme.colorScheme.outlineVariant;

    return Material(
      color: isSelected
          ? primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest,
      elevation: isSelected ? 2 : 0,
      shadowColor: primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                method == NotificationMethod.email
                    ? Icons.mark_email_read_outlined
                    : Icons.sms_outlined,
                color: isSelected
                    ? primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                size: 32,
              ),
              const SizedBox(height: 10),
              Text(
                method.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                Icon(Icons.check_circle, size: 18, color: primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
