import 'package:flutter/material.dart';


class PopoverMenuOption {
  const PopoverMenuOption({
    required this.label,
    required this.onTap,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool destructive;
}

class PopoverMenu extends StatefulWidget {
  const PopoverMenu({
    super.key,
    required this.trigger,
    required this.options,
  });

  final Widget trigger;
  final List<PopoverMenuOption> options;

  static void show(
    BuildContext context, {
    required Rect anchor,
    required List<PopoverMenuOption> options,
  }) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        anchor,
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: options.map((opt) => PopupMenuItem<String>(
        value: opt.label,
        onTap: opt.onTap,
        child: Row(
          children: [
            if (opt.icon != null) ...[
              Icon(opt.icon, size: 20, color: opt.destructive
                ? Theme.of(context).colorScheme.error
                : null),
              const SizedBox(width: 10),
            ],
            Text(
              opt.label,
              style: TextStyle(
                color: opt.destructive
                  ? Theme.of(context).colorScheme.error
                  : null,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  @override
  State<PopoverMenu> createState() => _PopoverMenuState();
}

class _PopoverMenuState extends State<PopoverMenu> {
  final _key = GlobalKey<State>();

  void _show() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    PopoverMenu.show(
      context,
      anchor: Rect.fromLTWH(
        position.dx,
        position.dy + renderBox.size.height + 4,
        renderBox.size.width,
        0,
      ),
      options: widget.options,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _show,
      child: widget.trigger,
    );
  }
}
