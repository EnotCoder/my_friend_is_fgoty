# Changelog

**v1.1c**

## Fix: action_release() Crash on Unregistered Actions

---

- `Input.action_release()` throws a hard engine error (not a silent no-op) when called on an action that was never registered in the `InputMap` — confirmed directly from a Godot debugger trace (`Condition "!InputMap::get_singleton()->has_action(p_action)" is true`). This is more serious than "less reliable tracking," which is how the v1.4 entry below undersold it.
- This also affected the L/R/U/D movement mapping, not just Action Mapping: `_apply_axis()`'s zero-crossing branch and `_reset_actions()` unconditionally called `action_release()` on `action_left/right/up/down`. If those were set to custom names (e.g. `"move_left"`, exactly what the README's own Player Script example recommends) that were never manually registered, the very first touch that landed dead-center (`value == 0`) would crash.
- Fixed by calling the same `_ensure_action_registered()` from v1.4 before every `action_press`/`action_release` in `_apply_axis()` and `_reset_actions()`, not just in the Action Mapping bindings.

**v1.1b**

## Action Mapping — Reliable Pulse Detection

---

- New signal `action_fired(action_name: StringName, strength: float)`, emitted the instant any binding presses its action — both on a held-type's initial activation and on a pulse-type's momentary press. Connect to it instead of polling `Input` for `ON_RELEASE`/`TAP_GESTURE`.
- Why: `ON_RELEASE`/`TAP_GESTURE` press then release their action within the same frame (`call_deferred`). By the time another node's `_physics_process` polls `Input.is_action_just_pressed()`, the deferred release may have already resolved, making the "just pressed" check unreliable — `is_action_just_released()` catches it correctly, but by then `Input.get_action_strength()` has already dropped back to 0, so the release strength is lost. `action_fired` sidesteps both problems by handing you the exact strength synchronously, at the exact moment it happens.
- Every binding's `action_name` is now auto-registered via `InputMap.add_action()` the first time it fires, if it wasn't already present in Project Settings. Ad-hoc action names generally work fine for `is_action_pressed()` (used by `ON_TOUCH`/`CONTINUOUS`/`ON_THRESHOLD`), but `is_action_just_pressed()`/`is_action_just_released()` are more reliable once the action is registered — this removes the need to register it by hand.
- If you still prefer polling over the signal, use `is_action_just_released()` for `ON_RELEASE`/`TAP_GESTURE`, not `is_action_just_pressed()` — and read the strength from the `action_fired` signal rather than `get_action_strength()`, since the latter is 0 by the time the action reads as released.

**v1.1a**

## Action Mapping — Expanded Trigger Modes

---

- `TriggerMode` grew from `{ ON_TOUCH, ON_THRESHOLD }` (v1.2) to `{ ON_TOUCH, CONTINUOUS, ON_THRESHOLD, ON_RELEASE, TAP_GESTURE }` — the original two are kept as-is, three more were added alongside them.
- `ON_TOUCH`: presses as soon as the control is touched, releases on touch end (unchanged from v1.2).
- `CONTINUOUS`: fires while displacement is past the stick's own shared `deadzone`. Unlike `ON_THRESHOLD`, it needs no extra field — it reuses `deadzone` directly.
- `ON_THRESHOLD`: fires past its own independent `threshold` (0.0–1.0), decoupled from `deadzone` — lets two different bindings on the same stick activate at two different distances (unchanged from v1.2).
- `ON_RELEASE`: fires once, exactly when the touch ends, with `strength` set to the stick's own output magnitude (`value.length()`) just before releasing. Useful for charge-and-release mechanics.
- `TAP_GESTURE`: fires once if the touch is released within `tap_max_duration` (new field, only shown for this mode) and never moved past the deadzone during its whole lifetime — a genuine tap, not a drag.
- `ON_RELEASE` and `TAP_GESTURE` press their action for exactly one frame (via `call_deferred`) instead of holding it, since both represent a momentary trigger rather than a held button. The other three hold the action for as long as their own condition stays true.
- Default `action_name` changed to `"fire"`.


**v1.1**

## Centered Pivot Offset

---

- `pivot_offset` is now automatically kept at the center of the node (`size / 2.0`), both on `_ready()` and on every resize (`NOTIFICATION_RESIZED`). Applies to both Joystick and D-Pad styles alike, since it only depends on `size`.
- Ensures any future `scale` or `rotation` applied to the control (e.g. a press "punch" tween) pivots from the visual center instead of the top-left corner.
- Hidden from the Inspector (`_validate_property`), since it's now fully code-managed and any manual edit would be overwritten on the next resize.

## Action Mapping

---

- New `vjdx_action_binding.gd` (VJDXActionBinding): a `Resource` describing a single configurable action — `action_name` (InputMap action), `trigger_mode` (`ON_TOUCH` or `ON_THRESHOLD`), and `threshold` (0.0–1.0, same unit as `deadzone`).
- New `action_bindings: Array[VJDXActionBinding]` export under a new "Action Mapping" subgroup inside the existing "Input Mapping" category. Add as many bindings as needed, each with its own activation rule — works on both Joystick and D-Pad styles.
- New `use_directional_mapping: bool` toggle to enable/disable the existing L/R/U/D action-press mapping independently of `action_bindings`, so a single control can drive movement actions, action bindings, or both at once.
- `ON_TOUCH` bindings press their action as soon as the control is touched and release on touch end. `ON_THRESHOLD` bindings press only once displacement passes their own `threshold`, and release either when displacement drops back below it or on touch end, whichever comes first.
- Added a configuration warning for any binding left without an `action_name`.



**v1.0**

## Complete Architectural Refactoring & Modularization

---

- **Monolithic Core Separation:** Split the large core script into highly specialized, decoupled helper classes to improve code maintainability, clean execution, and readability.
  - `vjdx_core_script.gd` (Control Core / Orchestrator): Handles property exports for the Inspector, scene lifecycle, and general input routing.
  - `vjdx_renderer.gd` (VJDXRenderer): A stateless static rendering helper class that takes over all 2D custom canvas drawing.
  - `vjdx_region.gd` (VJDXRegion): Manages viewport boundaries, global-to-local calculations, and dynamic active region clamping.
  - `vjdx_haptics.gd` (VJDXHaptics): Safely wraps mobile platform-specific vibration APIs (`Input.vibrate_handheld`).
  - `vjdx_hardware_detector.gd` (VJDXHardwareDetector): Isolated polling logic for keyboards and external gamepad connections to toggle dynamic visibility.
  - `vjdx_joystick_handler.gd` (VJDXJoystickHandler): Fully owns the Joystick's movement-mode logic — deadzone mapping, proportional speed, activation checks (DYNAMIC/FOLLOWING), clampzone release, and reposition-target computation — on par with the D-Pad handler's ownership model.
  - `vjdx_dpad_handler.gd` (VJDXDpadHandler): Processes 8-way octant mapping, state transitions, and manages custom/preset SVG texture states.
- **Rendering Performance Optimization:** Separated the canvas redrawing routine (`_draw()`) from physics and touch state updates. This prevents redundant drawing calculation loops.
- **API and UI Preservation:** Maintained backward compatibility. The unified Inspector layout and API interface remain unchanged, allowing developers to switch between modes seamlessly on a single control node instance.

**v0.4**

## Haptic Feedback

---

- Haptic feedback added.
- Independent values for Joystick and D-Pad.
Each controller mode (Joystick, D-Pad) has its own set of haptic feedback settings.
- Configurable duration and intensity of haptic feedback.

Read the README.md file to learn more.