/*
 * Copyright (C) 2012, 2020 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "config.h"
#import "AlternativeTextUIController.h"

#if USE(DICTATION_ALTERNATIVES)

#import <WebCore/FloatRect.h>

#if USE(APPKIT)
#import <AppKit/NSSpellChecker.h>
#import <AppKit/NSTextAlternatives.h>
#import <AppKit/NSView.h>
#elif PLATFORM(IOS_FAMILY)
#import <pal/spi/ios/UIKitSPI.h>
#endif

namespace WebCore {

uint64_t AlternativeTextUIController::addAlternatives(const RetainPtr<NSTextAlternatives>& alternatives)
{
    return m_contextController.addAlternatives(alternatives);
}

Vector<String> AlternativeTextUIController::alternativesForContext(uint64_t context)
{
    NSTextAlternatives *textAlternatives = m_contextController.alternativesForContext(context);
    Vector<String> alternativeStrings;
    alternativeStrings.reserveInitialCapacity(textAlternatives.alternativeStrings.count);
    for (NSString *string in textAlternatives.alternativeStrings)
        alternativeStrings.uncheckedAppend(string);
    return alternativeStrings;
}

void AlternativeTextUIController::clear()
{
    return m_contextController.clear();
}

void AlternativeTextUIController::showAlternatives(NSView *view, const FloatRect& boundingBoxOfPrimaryString, uint64_t context, AcceptanceHandler acceptanceHandler)
{
#if USE(APPKIT)
    dismissAlternatives();
    if (!view)
        return;

    m_view = view;

    NSTextAlternatives *alternatives = m_contextController.alternativesForContext(context);
    if (!alternatives)
        return;

    [[NSSpellChecker sharedSpellChecker] showCorrectionIndicatorOfType:NSCorrectionIndicatorTypeGuesses primaryString:alternatives.primaryString alternativeStrings:alternatives.alternativeStrings forStringInRect:boundingBoxOfPrimaryString view:m_view.get() completionHandler:^(NSString *acceptedString) {
        if (acceptedString) {
            handleAcceptedAlternative(acceptedString, context, alternatives);
            acceptanceHandler(acceptedString);
        }
    }];
#else
    UNUSED_PARAM(view);
    UNUSED_PARAM(boundingBoxOfPrimaryString);
    UNUSED_PARAM(context);
    UNUSED_PARAM(acceptanceHandler);
#endif
}

#if USE(APPKIT)

void AlternativeTextUIController::handleAcceptedAlternative(NSString *acceptedAlternative, uint64_t context, NSTextAlternatives *alternatives)
{
    [alternatives noteSelectedAlternativeString:acceptedAlternative];
    m_contextController.removeAlternativesForContext(context);
    m_view = nullptr;
}

void AlternativeTextUIController::dismissAlternatives()
{
    if (m_view)
        [[NSSpellChecker sharedSpellChecker] dismissCorrectionIndicatorForView:m_view.get()];
}

#endif

void AlternativeTextUIController::removeAlternatives(uint64_t context)
{
    m_contextController.removeAlternativesForContext(context);
}

} // namespace WebCore

#endif // USE(DICTATION_ALTERNATIVES)
