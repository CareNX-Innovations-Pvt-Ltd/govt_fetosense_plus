import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class SwitchPreference extends StatefulWidget {
  final String title;
  final String? desc;
  final String localKey;
  final bool defaultVal;
  final bool ignoreTileTap;

  final bool resetOnException;

  final Function? onEnable;
  final Function? onDisable;
  final Function? onChange;

  final bool disabled;

  final Color? switchActiveColor;

  SwitchPreference(
    this.title,
    this.localKey, {
    this.desc,
    this.defaultVal = false,
    this.ignoreTileTap = false,
    this.resetOnException = true,
    this.onEnable,
    this.onDisable,
    this.onChange,
    this.disabled = false,
    this.switchActiveColor,
  });

  _SwitchPreferenceState createState() => _SwitchPreferenceState();
}

class _SwitchPreferenceState extends State<SwitchPreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.getBool(widget.localKey) == null) {
      PrefService.setBool(widget.localKey, widget.defaultVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title,style: Theme.of(context).textTheme.labelLarge,),
      subtitle: widget.desc == null ? null : Text(widget.desc!,style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54),),
      trailing: Switch.adaptive(
        value: PrefService.getBool(widget.localKey) ?? widget.defaultVal,
        activeColor: widget.switchActiveColor,
        onChanged:
            widget.disabled ? null : (val) => val ? onEnable() : onDisable(),
      ),
      onTap: (widget.disabled || widget.ignoreTileTap)
          ? null
          : () => (PrefService.getBool(widget.localKey) ?? widget.defaultVal)
              ? onDisable()
              : onEnable(),
    );
  }

  onEnable() async {
    setState(() => PrefService.setBool(widget.localKey, true));
    if (widget.onChange != null) widget.onChange!();
    if (widget.onEnable != null) {
      try {
        await widget.onEnable!();
      } catch (e) {
        if (widget.resetOnException) {
          PrefService.setBool(widget.localKey, false);
          if (mounted) setState(() {});
        }
        if (mounted) PrefService.showError(context, e.toString());
      }
    }
  }

  onDisable() async {
    setState(() => PrefService.setBool(widget.localKey, false));
    if (widget.onChange != null) widget.onChange!();
    if (widget.onDisable != null) {
      try {
        await widget.onDisable!();
      } catch ( e) {
        if (widget.resetOnException) {
          PrefService.setBool(widget.localKey, true);
          if (mounted) setState(() {});
        }
        if (mounted) PrefService.showError(context, e.toString());
      }
    }
  }
}
