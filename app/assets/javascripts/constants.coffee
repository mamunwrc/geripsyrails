geripsy.constant 'CONSTANTS', (() ->
    constants =
        APIUrl: '/api/'
        SystemStrings:
            SITE_NAME: "GeriPsy EHR"

        BroadcastMessages:
            SESSION_CHANGED: 'sessionChanged'
            DISPLAY_ALERT: 'displayAlert'
            DISPLAY_REMINDER: 'displayReminder'
            DISPLAY_MESSAGE: 'displayMessage'

        Events:
            WINDOW_WIDTH_CHANGED: 'windowWidthChanged'
            WINDOW_SCROLL: 'windowScroll'

        ElementAnchors:
            TOP_NAVIGATION_BAR: 'top-navbar',
            TOP_NAVIGATION_BAR_PLACEHOLDER: 'top-navbar-placeholder',
            TOP_MOBILE_TOOLBAR: 'top-mobile-toolbar'

        Timeouts:
            POOLING_INTERVAL: 10000

        SessionStorage:
            AUTH_TOKEN: 'authToken'
            USER_ID: 'userId'
            USER_NAME: 'userName'
            SESSION_ID: 'sessionId'
            USER_ROLE: 'userRole'
            ENCOUNTER_ID: 'encounterId'
            PATIENT_ID: 'patientId'
            PROVIDER_ID: 'providerId'

        LoginPages:
            LOGIN: 'login'
            SIGNUP: 'signup'
            MESSAGE: 'message'
            FACADE: 'facade'
            FORGOTPASSWORD: 'forgotpwd'

        LoginStates:
            SIGNUP: 'signup'
            FORGOTPASSWORD: 'forgotpassword'

        RoutingStates:
            LOGIN: 'login'
            LOGOUT: 'logout'
            HOME: 'home'
            USER_PROFILE: 'profile'
            PATIENT: 'patients'
            PROVIDER: 'providers'
            CHAT: 'chat'
            ADMIN: 'admin'
            FACILITY: 'facilities'
            ENCOUNTER: 'encounters'

        Pagination:
            PAGE_LIMIT: 25

        DataFiles:
            REFLOOKUP: 'src/resources/data/GeriPsy_ref_lookup.txt'

        EMAIL_REGEX: /^[\w._]+@[\w._]+$/
        DEFAULT_AVATAR_URL: 'resources/images/in_page_img/def_avatar.png'
        EMPTY_SESSION_ID: '00000000-0000-0000-0000-000000000000'
        CHAT_MESSAGES_LIMIT: 5
        MAXIMUM_CHAT_TEXT_LENGTH: 256

    geripsy.constant 'appConfig', constants 
    return constants
)()


