#!/usr/bin/env bash
set -e

mkdir -p /etc/firefox/policies

# Multi-line write syntax
cat <<EOF_FF > /etc/firefox/policies/policies.json
{
  "policies": {
    "BlockAboutSupport": true,
    "DisableAppUpdate": true,
    "DisableFirefoxAccounts": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableTelemetry": true,
    "OfferToSaveLogins": false,
    "PrintingEnable": false,
    "AutofillAddressEnabled": false,
    "SearchBar": "separate",
    "WindowsSSO": false,
    "UserMessaging": {
      "WhatsNew": false,
      "ExtensionRecommendations": false,
      "FeatureRecommendations": false,
      "UrlbarIntervention":false,
      "SkipOnboarding": true,
      "MoreFromMozilla": false,
      "Locked": true
  },
  "DisableSecurityBypass": {
    "InvalidCertificate": true,
    "SafeBrowsing": false
  },
  "DNSOverHTTPS": {
    "Enabled": false,
    "Locked": true
  },
  "Proxy": {
    "Mode": "none",
    "Locked": true
  },
  "EnableTrackingProtection": {
    "Value": true,
    "Locked": true,
    "Cryptomining": true,
    "Fingerprinting": true
  },
  "SanitizeOnShutdown": {
    "Cache": true,
    "Cookies": false,
    "Downloads": true,
    "FormData": true,
    "History": true,
    "Sessions": false,
    "SiteSettings": false,
    "OfflineApps": true
  },
  "ExtensionSettings": {
    "*": {
      "blocked_install_message": "Blocked.",
      "installation_mode": "blocked",
      "allowed_types": ["extension"]
    },
    "uBlock0@raymondhill.net": {
      "installation_mode": "force_installed",
      "install_url": "https:addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
    },
    "https-everywhere@eff.org": {
      "installation_mode": "force_installed",
      "updates_disabled": false
    },
    "pictureinpicture@mozilla.org": {
      "installation_mode": "blocked",
      "updates_disabled": false
    },
    "screenshots@mozilla.org": {
      "installation_mode": "blocked",
      "updates_disabled": false
    },
    "formautofill@mozilla.org": {
      "installation_mode": "blocked",
      "updates_disabled": false
    },
    "google@search.mozilla.org": {
      "installation_mode": "blocked",
      "updates_disabled": false
    },
    "bing@search.mozilla.org": {
      "installation_mode": "blocked",
      "updates_disabled": false
    },
    "ddg@search.mozilla.org": {
      "installation_mode": "blocked",
      "updates_disabled": false
    }
  },
  "SearchEngines": {
    "Add": [
      {
        "Name": "Startpage",
        "URLTemplate": "https://www.startpage.com/sp/search?query={searchTerms}&prfe=c6dd2591b8c03bb60984f8779b043f73f3679f62e117240fdfcef05d82518777855fd0ea5cf676ec8731ca8f1cfd7c5812710dfc1645439dee9eb6a20267d9c9066f528870392e3d31d58499bc3d",
        "Method": "GET",
        "IconURL": "https://www.startpage.com/favicon.ico",
        "Alias": "startpage",
        "Description": "Private search engine."
      }
    ],
    "Remove": [
      "Google",
      "Amazon.com",
      "Bing",
      "eBay"
    ],
    "Default": "Startpage"
  },
  "FirefoxHome": {
    "Search": true,
    "TopSites": false,
    "SponsoredTopSites": false,
    "Highlights": false,
    "Pocket": false,
    "SponsoredPocket": false,
    "Snippets": false,
    "Locked": true
  },
  "FirefoxSuggest": {
    "WebSuggestions": false,
    "SponsoredSuggestions": false,
    "ImproveSuggest": false,
    "Locked": true
  },
  "Homepage": {
    "URL": "http://startpage.com/",
    "Locked": false,
    "StartPage": "homepage"
  },
  "Cookies": {
      "Block": ["https://l.google.com/", "https://l.youtube.com", "https://l.googleusercontent.com", "https://l.duckduckgo.com", "https://ajax.googleapis.com", "https://cloudinary.com", "https://gstatic.com", "https://startpage.com"],
      "Default": true,
      "RejectTracker": true,
      "Locked": true,
      "Behavior": "reject-tracker-and-partition-foreign",
      "BehaviorPrivateBrowsing": "reject-tracker-and-partition-foreign"
    },
    "Permissions": {
      "Camera": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Microphone": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Location": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Notifications": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "VirtualReality": {
        "BlockNewRequests": true,
        "Locked": true
      },
      "Autoplay": {
        "Default": "block-audio-video",
        "Locked": true
      }
    },
    "3rdparty": {
      "Extensions": {
        "uBlock0@raymondhill.net": {
          "userSettings": [
            [
              [ "prefetchingDisabled", "true" ],
              [ "autoUpdate", "false" ]
            ]
          ]
        },
        "adminSettings": {
          "advancedSettings": [
            [ "disableWebAssembly", "true" ],
            [ "uiTheme", "dark" ]
          ],
          "advancedUserEnabled": "true",
          "selectedFilterLists": [
            "user-filters",
            "ublock-filters",
            "ublock-badware",
            "ublock-privacy",
            "ublock-quick-fixes",
            "ublock-unbreak",
            "easylist",
            "adguard-generic",
            "adguard-mobile",
            "easyprivacy",
            "adguard-spyware",
            "adguard-spyware-url",
            "block-lan",
            "urlhaus-1",
            "curben-phishing",
            "plowe-0",
            "dpollock-0",
            "ublock-cookies-easylist",
            "adguard-cookies",
            "ublock-cookies-adguard",
            "adguard-social",
            "easylist-chat",
            "easylist-newsletters",
            "easylist-notifications",
            "easylist-annoyances",
            "adguard-mobile-app-banners",
            "adguard-other-annoyances",
            "adguard-popup-overlays",
            "adguard-widgets",
            "ublock-annoyances"
          ]
        }
      }
    }
  }
}
EOF_FF
