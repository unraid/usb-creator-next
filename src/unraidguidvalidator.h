#include "dependencies/drivelist/src/drivelist.hpp"

#include <curl/curl.h>

#include <QString>

class UnraidGuidValidator {
public:
    UnraidGuidValidator();
    ~UnraidGuidValidator();

    struct Result {
        QString guid{""};
        bool guidValid{false};
    };
    
    Result checkDevice(const Drivelist::DeviceDescriptor& deviceDescriptor);
protected:
    CURL *_curl{nullptr};
};
