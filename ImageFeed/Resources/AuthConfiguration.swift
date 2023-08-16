import Foundation

let defaultBaseURL = URL(string: "https://api.unsplash.com")!
let authorizeURLString = "https://unsplash.com/oauth/authorize"
let accessKey = "TbwYppOYfX1PCfLUAVG2pClO6BGfT-jpzkew6DaOfss"
let secretKey = "CaOqcQWBmlcU6EMJZvxiYtxxyQE8ArzrBJqgfdpbmn8"
let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
let accessScope = "public+read_user+write_likes"

struct AuthConfiguration {
    let access_Key: String
    let secret_Key: String
    let redirect_URI: String
    let access_Scope: String
    let default_Base_URL: URL
    let authorize_URL_String: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: accessKey,
                                 secretKey: secretKey,
                                 redirectURI: redirectURI,
                                 accessScope: accessScope,
                                 authorizeURLString: authorizeURLString,
                                 defaultBaseURL: defaultBaseURL)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authorizeURLString: String, defaultBaseURL: URL) {
        self.access_Key = accessKey
        self.secret_Key = secretKey
        self.redirect_URI = redirectURI
        self.access_Scope = accessScope
        self.default_Base_URL = defaultBaseURL
        self.authorize_URL_String = authorizeURLString
    }
}
