#!/usr/bin/env bash

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# get script directory to reference
SCRIPT_SOURCE=${BASH_SOURCE[0]/%utils_tests.sh/}
# shellcheck disable=SC1091
# shellcheck source=common/loggers.sh
source "${SCRIPT_SOURCE}../../common/loggers.sh"
# shellcheck disable=SC1091
# shellcheck source=common/utils.sh
source "${SCRIPT_SOURCE}../../common/utils.sh"
# shellcheck disable=SC1091
# shellcheck source=common/help.sh
source "${SCRIPT_SOURCE}../../common/help.sh"

export DEBUG=1

__log_info "Beginning Unit Test Execution."


function __generate_random_string_does_not_generate_same_value_in_a_row() {
    __log_info "TEST: Random String should not generate the same value twice."
    ONEVAL=$(__generate_random_string)
    TWOVAL=$(__generate_random_string)
    if [[ $ONEVAL == $TWOVAL ]]; then
        __log_error "First Value: ${ONEVAL}"
        __log_error "Second Value: ${TWOVAL}"
        __log_error "TEST FAILED X"
        exit 1
    else
        __log_info "Test Completed Successfully."
    fi
}


__generate_random_string_does_not_generate_same_value_in_a_row

function __to_upper_should_uppercase_strings() {
    __log_info "TEST: To Upper should uppercase strings"
    VAL="abc123HelpMe"
    result=$(__toUpper $VAL)
    if [[ "$result" != "ABC123HELPME" ]]; then
        __log_error "Expected: ABC123HELPME"
        __log_error "Actual: ${result}"
        __log_error "TEST FAILED X"
        exit 1
    else
        __log_info "Test Completed Successfully."
    fi
}

__to_upper_should_uppercase_strings

function __element_in_should_return_0_for_match() {
    __log_info "TEST: ElementIn should return 0 for an element that is in an array"
    ARR=("ONE" "TWO" "THREE" "FOUR" "FIVE")
    ARG="THREE"
    result=$(__elementIn "${ARG}" "${ARR[@]}")
    if [[ "$result" != "0" ]]; then
        __log_error "$result"
        __log_error "${ARG} was not found in ${ARR[*]}"
        exit 1
    else
        __log_info "Test Completed Successfully."
    fi
}

__element_in_should_return_0_for_match

function __versionComparisonShouldReturn0ForEqual() {
    __log_info "TEST: Version comparison should return 0 for equal versions"
    ARG1="6.5.0"
    ARG2="6.5.0"
    RET=$(__compareVersions $ARG1 $ARG2)
    if [[ "$RET" != "0" ]]; then
        __log_error "Expected: 0"
        __log_error "Actual: ${RET}"
        __log_error "TEST FAILED X"    
    else
        __log_info "Test Completed Successfully."
    fi
}

__versionComparisonShouldReturn0ForEqual

function __versionComparisonShouldReturn2ForGreaterThan() {
    __log_info "TEST: Version comparison should return 2 for a greater versions"
    ARG1="6.5.0"
    ARG2="6.6.0"
    RET=$(__compareVersions $ARG1 $ARG2)
    if [[ "$RET" != "2" ]]; then
        __log_error "Expected: 2"
        __log_error "Actual: $RET"
        __log_error "TEST FAILED X"    
    else
        __log_info "Test Completed Successfully."
    fi
}

__versionComparisonShouldReturn2ForGreaterThan

function __versionComparisonShouldReturn1ForLesserThan() {
    __log_info "TEST: Version comparison should return 1 for a lesser version"
    ARG1="6.6.1"
    ARG2="6.6.0"
    RET=$(__compareVersions $ARG1 $ARG2)
    if [[ "$RET" != "1" ]]; then
        __log_error "Expected: 1"
        __log_error "Actual: $RET"
        __log_error "TEST FAILED X"    
    else
        __log_info "Test Completed Successfully."
    fi
}

__versionComparisonShouldReturn1ForLesserThan

function __findClosestVersionShouldErrorWithImproperVersion() {
    __log_info "TEST:  Find Closest Version should exit if version not in appropriate format"
    ARR=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
    ARG="AB35.323.3"
    set +e
    ret=$(__findClosestVersion "${ARG}" "${ARR[@]}")
    if [[ "$?" != "1" ]]; then
        echo "$ret"
        exit 1
    else
        __log_info "Test Completed Successfully."
    fi
}

__findClosestVersionShouldErrorWithImproperVersion

function __findClosestVersionShouldReturnValueIfExistsInArray() {
    __log_info "TEST:  Find Closest Version should exit if version not in appropriate format"
    ARR=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
    ARG="6.6.1"
    set +e
    ret=$(__findClosestVersion "${ARG}" "${ARR[@]}")
    if [[ "$?" != "0" ]]; then
        echo "$ret"
        exit 1
    else
        __log_debug "Value Returned: ${ret}"
        __log_info "Test Completed Successfully."
    fi
}

__findClosestVersionShouldReturnValueIfExistsInArray

function __findClosestVersionShouldFindNearestVersionIfNotPresentAndPriorToAll() {
    __log_info "TEST:  Find Closest Version should exit if version not in appropriate format"
    ARR=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
    ARG="5.0.0"
    set +e
    ret=$(__findClosestVersion "${ARG}" "${ARR[@]}")
    if [[ "$ret" != "6.5.0" ]]; then
        __log_error "Expected: 6.5.0"
        __log_error "Actual: ${ret}"
        __log_error "TEST FAILED X"
        exit 1
    else
        __log_debug "Value Returned: ${ret}"
        __log_info "Test Completed Successfully."
    fi
}

__findClosestVersionShouldFindNearestVersionIfNotPresentAndPriorToAll

function __findClosestVersionShouldFindNearestVersionIfNotPresentAndBetween() {
    __log_info "TEST:  Find Closest Version should exit if version not in appropriate format"
    ARR=("6.5.0" "6.5.1" "6.6.0" "6.6.1")
    ARG="6.5.5"
    set +e
    ret=$(__findClosestVersion "${ARG}" "${ARR[@]}")
    if [[ "$ret" != "6.5.1" ]]; then
        __log_error "Expected: 6.5.1"
        __log_error "Actual: ${ret}"
        __log_error "TEST FAILED X"
        exit 1
    else
        __log_debug "Value Returned: ${ret}"
        __log_info "Test Completed Successfully."
    fi
}

__findClosestVersionShouldFindNearestVersionIfNotPresentAndBetween