#include "mac_suspend_inhibitor.h"
#include "branding.h" // UNRAID

#include <IOKit/pwr_mgt/IOPMLib.h>

MacSuspendInhibitor::MacSuspendInhibitor()
{
    CFStringRef name = CFSTR(IMAGER_APP_NAME); // UNRAID

    // Prevent system sleep
    auto result = IOPMAssertionCreateWithName(
        kIOPMAssertionTypePreventUserIdleSystemSleep,
        kIOPMAssertionLevelOn,
        name,
        &_systemSleepAssertion);
        
    if (result != kIOReturnSuccess)
        _systemSleepAssertion = kIOPMNullAssertionID;

    // Prevent display sleep
    result = IOPMAssertionCreateWithName(
        kIOPMAssertionTypeNoDisplaySleep,
        kIOPMAssertionLevelOn,
        name,
        &_displaySleepAssertion);
        
    if (result != kIOReturnSuccess)
        _displaySleepAssertion = kIOPMNullAssertionID;
}

/*virtual*/ MacSuspendInhibitor::~MacSuspendInhibitor()
{
    if (_systemSleepAssertion != kIOPMNullAssertionID)
    {
        IOPMAssertionRelease(_systemSleepAssertion);
        _systemSleepAssertion = kIOPMNullAssertionID;
    }

    if (_displaySleepAssertion != kIOPMNullAssertionID)
    {
        IOPMAssertionRelease(_displaySleepAssertion);
        _displaySleepAssertion = kIOPMNullAssertionID;
    }
}

SuspendInhibitor *CreateSuspendInhibitor()
{
    return new MacSuspendInhibitor();
}
