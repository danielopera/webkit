/*
 * Copyright (C) 2014 Daniel Lazarenko (danielo@opera.com)
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

#ifndef ResourceRequestWithBody_h
#define ResourceRequestWithBody_h

#if ENABLE(CUSTOM_PROTOCOLS)

#include "ResourceRequest.h"

namespace WebCore {

class ResourceRequestWithBody {
public:
    ResourceRequestWithBody() { }
    ResourceRequestWithBody(const ResourceRequest& request)
        : m_request(request) { }
    const ResourceRequest& request() const { return m_request; }

#if ENABLE(CACHE_PARTITIONING)
    const String& cachePartition() const { return m_request.cachePartition(); }
#endif

#if ENABLE(INSPECTOR)
    // Whether this request should be hidden from the Inspector.
    bool hiddenFromInspector() const { return m_request.hiddenFromInspector(); }
#endif

    bool encodingRequiresPlatformData() const { return m_request.encodingRequiresPlatformData(); }

    template<class Encoder> void encodeWithoutPlatformData(Encoder& encoder) const { m_request.encodeWithoutPlatformData(encoder); }

private:
    ResourceRequest m_request;

};

}; // namespace WebCore

#endif // ENABLE(CUSTOM_PROTOCOLS)

#endif // ResourceRequestWithBody_h
