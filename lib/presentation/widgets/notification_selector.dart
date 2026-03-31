import 'package:flutter/material.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';

class NotificationSelector extends FormField<NotificationMethod> {
  NotificationSelector({
    super.key,
    super.initialValue,
    required ValueChanged<NotificationMethod?> onChanged,
    super.validator,
  }) : super(
          builder: (FormFieldState<NotificationMethod> fieldState) {
            final theme = Theme.of(fieldState.context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Método de notificación',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
    final borderColor = hasError && !isSelected
        ? theme.colorScheme.error
        : isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(
              method == NotificationMethod.email
                  ? Icons.email_outlined
                  : Icons.sms_outlined,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              method.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
