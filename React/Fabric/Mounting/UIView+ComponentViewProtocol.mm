/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UIView+ComponentViewProtocol.h"

#import <React/RCTAssert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

#import "RCTConversions.h"

using namespace facebook::react;

@implementation RCTUIView (ComponentViewProtocol)

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  RCTAssert(NO, @"`-[RCTComponentViewProtocol componentDescriptorProvider]` must be implemented in a concrete class.");
  return {};
}

+ (std::vector<facebook::react::ComponentDescriptorProvider>)supplementalComponentDescriptorProviders
{
  return {};
}

#if !TARGET_OS_OSX // TODO(macOS we don't use this class either way, so just remove this code)
- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  RCTAssert(childComponentView.superview == nil, @"Attempt to mount already mounted component view.");
  [self insertSubview:childComponentView atIndex:index];
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  RCTAssert(childComponentView.superview == self, @"Attempt to unmount improperly mounted component view.");
  RCTAssert(
      [self.subviews objectAtIndex:index] == childComponentView,
      @"Attempt to unmount improperly mounted component view.");

  [childComponentView removeFromSuperview];
}
#endif

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  // Default implementation does nothing.
}

- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter
{
  // Default implementation does nothing.
}

- (void)updateState:(facebook::react::State::Shared const &)state
           oldState:(facebook::react::State::Shared const &)oldState
{
  // Default implementation does nothing.
}

- (void)handleCommand:(NSString *)commandName args:(NSArray *)args
{
  // Default implementation does nothing.
}

- (void)updateLayoutMetrics:(LayoutMetrics const &)layoutMetrics
           oldLayoutMetrics:(LayoutMetrics const &)oldLayoutMetrics
{
  bool forceUpdate = oldLayoutMetrics == EmptyLayoutMetrics;

  if (forceUpdate || (layoutMetrics.frame != oldLayoutMetrics.frame)) {
    CGRect frame = RCTCGRectFromRect(layoutMetrics.frame);

    if (!std::isfinite(frame.origin.x) || !std::isfinite(frame.origin.y) || !std::isfinite(frame.size.width) ||
        !std::isfinite(frame.size.height)) {
      // CALayer will crash if we pass NaN or Inf values.
      // It's unclear how to detect this case on cross-platform manner holistically, so we have to do it on the mounting
      // layer as well. NaN/Inf is a kinda valid result of some math operations. Even if we can (and should) detect (and
      // report early) incorrect (NaN and Inf) values which come from JavaScript side, we sometimes cannot backtrace the
      // sources of a calculation that produced an incorrect/useless result.
      RCTLogWarn(
          @"-[UIView(ComponentViewProtocol) updateLayoutMetrics:oldLayoutMetrics:]: Received invalid layout metrics (%@) for a view (%@).",
          NSStringFromCGRect(frame),
          self);
    } else {
      // Note: Changing `frame` when `layer.transform` is not the `identity transform` is undefined behavior.
      // Therefore, we must use `center` and `bounds`.
      self.frame.origin = CGPoint{CGRectGetMidX(frame), CGRectGetMidY(frame)};
      self.bounds = CGRect{CGPointZero, frame.size};
    }
  }

#if !TARGET_OS_OSX
  if (forceUpdate || (layoutMetrics.layoutDirection != oldLayoutMetrics.layoutDirection)) {
    self.semanticContentAttribute = layoutMetrics.layoutDirection == LayoutDirection::RightToLeft
        ? UISemanticContentAttributeForceRightToLeft
        : UISemanticContentAttributeForceLeftToRight;
  }
#endif

  if (forceUpdate || (layoutMetrics.displayType != oldLayoutMetrics.displayType)) {
    self.hidden = layoutMetrics.displayType == DisplayType::None;
  }
}

- (void)finalizeUpdates:(RNComponentViewUpdateMask)updateMask
{
  // Default implementation does nothing.
}

- (void)prepareForRecycle
{
  // Default implementation does nothing.
}

- (facebook::react::SharedProps)props
{
  RCTAssert(NO, @"props access should be implemented by RCTViewComponentView.");
  return nullptr;
}

@end
