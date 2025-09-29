import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A custom floating action button for starting new chats
///
/// This widget provides animated options for creating either a one-to-one chat
/// or a group chat with smooth animations and visual feedback.
class DashboardViewAnimatedChatButton extends StatefulWidget {
  const DashboardViewAnimatedChatButton({super.key});

  @override
  State<DashboardViewAnimatedChatButton> createState() => _DashboardViewAnimatedChatButtonState();
}

class _DashboardViewAnimatedChatButtonState extends State<DashboardViewAnimatedChatButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slidePrivateChatAnimation;
  late final Animation<double> _slideGroupChatAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

    // Main button animations
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.375).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Use double values for direct positioning
    _slidePrivateChatAnimation = Tween<double>(begin: 0, end: 80).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideGroupChatAnimation = Tween<double>(begin: 0, end: 160)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Create a fresh StreamUserListController for the new chat view
  StreamUserListController _createUserListController() {
    final client = StreamChat.of(context).client;
    final currentUser = client.state.currentUser;

    if (currentUser == null) {
      throw Exception('Cannot create user list controller: No authenticated user found');
    }

    return StreamUserListController(
      client: client,
      limit: 25,
      filter: Filter.and([Filter.notEqual('id', currentUser.id)]),
      sort: [const SortOption('name', direction: 1)],
    );
  }

  void _navigateToCreateChat(bool isGroup) {
    _toggleMenu();

    // Create a fresh controller just for this navigation
    final controller = _createUserListController();

    context.go(
      RouterEnum.createChatView.routeName,
      extra: {
        'userListController': controller,
        'isCreateNewChatPageForCreatingGroup': isGroup,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    // Constants for button sizes to ensure proper centering
    const double mainButtonSize = 64;
    const double optionButtonSize = 48;
    
    // Calculate the offset to properly center the option buttons
    final double buttonOffset = (mainButtonSize - optionButtonSize) / 2;

    return SizedBox(
      width: 220,
      height: 250,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildChatOption(
            animation: _slideGroupChatAnimation,
            label: appLocalizations?.groupChatOption ?? 'Group Chat',
            icon: Icons.group_rounded,
            color: customIndigoColorSecondary,
            onTap: () => _navigateToCreateChat(true),
            horizontalOffset: buttonOffset,
          ),
          _buildChatOption(
            animation: _slidePrivateChatAnimation,
            label: appLocalizations?.privateChatOption ?? 'Private Chat',
            icon: Icons.person,
            color: customIndigoColor,
            onTap: () => _navigateToCreateChat(false),
            horizontalOffset: buttonOffset,
          ),
          _buildMainButton(),
        ],
      ),
    );
  }

  Widget _buildChatOption({
    required Animation<double> animation,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double horizontalOffset,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          right: horizontalOffset,
          bottom: animation.value,
          child: Opacity(
            opacity: _animationController.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_animationController.value > 0.1)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: transparent,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: customGreyColor800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: label,
                          color: white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Material(
                  color: transparent,
                  elevation: 4,
                  shadowColor: color.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [color, Color.lerp(color, white, 0.15) ?? color],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: InkWell(
                      onTap: onTap,
                      customBorder: const CircleBorder(),
                      splashColor: whiteWithOpacity30,
                      child: Center(
                        child: Icon(icon, color: white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainButton() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Material(
        color: transparent,
        elevation: 6,
        shadowColor: customIndigoColor.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      buttonGradientActiveStart,
                      buttonGradientActiveEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: whiteWithOpacity30,
                  highlightColor: transparent,
                  onTap: _toggleMenu,
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(Icons.add_rounded, color: white, size: 32),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
