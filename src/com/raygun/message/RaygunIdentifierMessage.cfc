/**
 * Handles user identification data for Raygun error reports.
 * This component allows tracking errors by user to help identify user-specific issues
 * and patterns. The identifier can be any unique value like user ID or session ID.
 * Anonymous tracking is supported to maintain user privacy when needed.
 */
component accessors="true" {

    // Core identifier fields used to track errors by user
    property name="identifier"  type="string"  default="";
    property name="isAnonymous" type="boolean" default="";
    property name="email"       type="string"  default="";
    property name="fullName"    type="string"  default="";
    property name="firstName"   type="string"  default="";
    property name="uuid"        type="string"  default="";

    public RaygunIdentifierMessage function init(
        string identifier   = "",
        boolean isAnonymous = true,
        string email        = "",
        string fullName     = "",
        string firstName    = "",
        string uuid         = ""
    ) {
        setIdentifier( identifier );
        setIsAnonymous( isAnonymous );
        setEmail( email );
        setFullName( fullName );
        setFirstName( firstName );
        setUuid( uuid );
        return this;
    }

    /**
     * Formats user identification data for the Raygun API payload.
     * All fields are optional - Raygun will handle missing fields gracefully.
     * This flexibility allows varying levels of user tracking based on privacy needs.
     */
    public struct function build() {
        return {
            "identifier"  : getIdentifier(),
            "isAnonymous" : getIsAnonymous(),
            "email"       : getEmail(),
            "fullName"    : getFullName(),
            "firstName"   : getFirstName(),
            "uuid"        : getUuid()
        };
    }

}
