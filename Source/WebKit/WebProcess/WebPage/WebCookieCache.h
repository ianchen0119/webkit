/*
 * Copyright (C) 2020 Apple Inc. All rights reserved.
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

#pragma once

#include <WebCore/CookieJar.h>
#include <WebCore/SameSiteInfo.h>
#include <wtf/HashSet.h>

namespace WebCore {
class NetworkStorageSession;
}

namespace WebKit {

class WebCookieCache {
public:
    WebCookieCache() = default;

    bool isSupported();

    String cookiesForDOM(const URL& firstParty, const WebCore::SameSiteInfo&, const URL&, WebCore::FrameIdentifier, WebCore::PageIdentifier, WebCore::IncludeSecureCookies);
    void setCookiesFromDOM(const URL& firstParty, const WebCore::SameSiteInfo&, const URL&, WebCore::FrameIdentifier, WebCore::PageIdentifier, const String& cookieString);

    void cookiesAdded(const String& host, const Vector<WebCore::Cookie>&);
    void cookiesDeleted(const String& host, const Vector<WebCore::Cookie>&);
    void allCookiesDeleted();

    void clear();
    void clearForHost(const String&);

private:
    WebCore::NetworkStorageSession& inMemoryStorageSession();
    void pruneCacheIfNecessary();

    HashSet<String> m_hostsWithInMemoryStorage;
    std::unique_ptr<WebCore::NetworkStorageSession> m_inMemoryStorageSession;
};

} // namespace WebKit
