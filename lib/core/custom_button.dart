import 'package:flutter/material.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/22/2024, Friday

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.icon,
    this.isLast = false,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLast;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: EdgeInsets.only(right: isLast ? 0 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
        child: isLoading
            ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
            )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: Colors.white, size: 24), // Icon for the button
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
