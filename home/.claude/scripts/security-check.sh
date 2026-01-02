#!/bin/bash

# Security check script for Claude Code hooks
# Scans for sensitive data before file operations

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check content for sensitive patterns
check_sensitive_content() {
    local content="$1"
    local filename="$2"
    local found_issues=0
    
    # Patterns for sensitive data detection
    declare -a patterns=(
        # API Keys and Tokens
        "(?i)(api[_-]?key|apikey)\s*[:=]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"
        "(?i)(access[_-]?token|accesstoken)\s*[:=]\s*['\"][a-zA-Z0-9_.-]{20,}['\"]"
        "(?i)(secret[_-]?key|secretkey)\s*[:=]\s*['\"][a-zA-Z0-9_.-]{20,}['\"]"
        "(?i)(private[_-]?key|privatekey)\s*[:=]\s*['\"][a-zA-Z0-9_.-]{20,}['\"]"
        
        # Passwords
        "(?i)password\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "(?i)passwd\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        "(?i)pwd\s*[:=]\s*['\"][^'\"]{8,}['\"]"
        
        # Database connections
        "(?i)(mysql|postgres|mongodb)://[^/\s]+:[^@\s]+@"
        "(?i)jdbc:[^/\s]+://[^/\s]+:[^@\s]+@"
        
        # AWS/Cloud credentials
        "AKIA[0-9A-Z]{16}"
        "(?i)aws[_-]?secret[_-]?access[_-]?key"
        "(?i)aws[_-]?access[_-]?key[_-]?id"
        
        # Personal/Corporate Info
        "(?i)(email|mail)\s*[:=]\s*['\"][a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}['\"]"
        "(?i)(phone|tel)\s*[:=]\s*['\"][+]?[0-9\s\-\(\)]{10,}['\"]"
        
        # Credit card patterns
        "[0-9]{4}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4}"
        
        # SSH private keys
        "-----BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----"
        
        # JWT tokens
        "eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*"
        
        # IP addresses (internal networks)
        "(?:192\.168\.|10\.|172\.(?:1[6-9]|2[0-9]|3[01])\.)[0-9]{1,3}\.[0-9]{1,3}"
        
        # URLs with credentials
        "https?://[^/\s]*:[^@\s]*@[^/\s]+"
        
        # Common secret patterns
        "(?i)(client[_-]?secret|clientsecret)\s*[:=]\s*['\"][a-zA-Z0-9_.-]{20,}['\"]"
        "(?i)(auth[_-]?token|authtoken)\s*[:=]\s*['\"][a-zA-Z0-9_.-]{20,}['\"]"
    )
    
    # Check each pattern
    for pattern in "${patterns[@]}"; do
        if echo "$content" | grep -P "$pattern" > /dev/null 2>&1; then
            echo -e "${RED}⚠️  SECURITY ALERT: Potential sensitive data detected in $filename${NC}"
            echo -e "${YELLOW}Pattern matched: $pattern${NC}"
            echo -e "${YELLOW}Matched content:${NC}"
            echo "$content" | grep -P "$pattern" --color=always
            echo ""
            found_issues=1
        fi
    done
    
    # Additional checks for suspicious file extensions
    case "${filename##*.}" in
        key|pem|p12|pfx|jks|keystore)
            echo -e "${RED}⚠️  SECURITY ALERT: File appears to be a certificate/key file: $filename${NC}"
            found_issues=1
            ;;
        env)
            echo -e "${YELLOW}⚠️  WARNING: Environment file detected: $filename${NC}"
            echo -e "${YELLOW}Please verify no sensitive values are included${NC}"
            ;;
    esac
    
    # Check for common sensitive file names
    case "$(basename "$filename")" in
        *secret*|*password*|*credential*|*token*|*.env|.env.*|id_rsa|id_dsa|id_ecdsa|id_ed25519)
            echo -e "${YELLOW}⚠️  WARNING: Filename suggests sensitive content: $filename${NC}"
            ;;
    esac
    
    return $found_issues
}

# Main execution
main() {
    # Get the tool name and arguments from Claude (passed as environment variables)
    local tool_name="${CLAUDE_TOOL_NAME:-unknown}"
    local file_path="${CLAUDE_TOOL_FILE_PATH:-}"
    
    # Only check file operations
    case "$tool_name" in
        Write|Edit|MultiEdit)
            if [[ -n "$file_path" && -f "$file_path" ]]; then
                echo -e "${GREEN}🔒 Running security check on: $file_path${NC}"
                
                # Read file content
                local content
                content=$(cat "$file_path" 2>/dev/null)
                
                if [[ $? -eq 0 ]]; then
                    check_sensitive_content "$content" "$file_path"
                    local result=$?
                    
                    if [[ $result -eq 1 ]]; then
                        echo -e "${RED}❌ SECURITY CHECK FAILED${NC}"
                        echo -e "${RED}Sensitive data detected. Please review and remove before proceeding.${NC}"
                        exit 1
                    else
                        echo -e "${GREEN}✅ Security check passed${NC}"
                    fi
                fi
            fi
            ;;
        *)
            # For non-file operations, just exit successfully
            exit 0
            ;;
    esac
}

# Run main function
main "$@"
