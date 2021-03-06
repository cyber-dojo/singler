
[![Build Status](https://travis-ci.org/cyber-dojo/singler.svg?branch=master)](https://travis-ci.org/cyber-dojo/singler)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/singler docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Creates individual practice sessions.
- Stores the visible files, output, and traffic-light status of every test event.
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha](#get-sha)
- [GET kata_exists?](#get-kata_exists)
- [POST kata_create](#post-kata_create)
- [GET kata_manifest](#get-kata_manifest)
- [POST kata_ran_tests](#post-kata_ran_tests)
- [GET kata_tags](#get-kata_tags)
- [GET kata_tag](#get-kata_tag)

- - - -

## GET sha
Returns the git commit sha used to create the docker image.
- parameters, none
```
  {}
```
- returns the sha, eg
```
  { "sha": "afe46e4bba4c7c5b630ef7fceda52f29001a10da" }
```

- - - -

## POST kata_create
Creates a practice-session from the given manifest
and visible_files.
- parameters, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
                               "hiker.h": "#ifndef HIKER_INCLUDED...",
                               "hiker.c": "#include \"hiker.h\"...",
                        "hiker.tests.c" : "#include <assert.h>\n...",
                         "instructions" : "Write a program that...",
                             "makefile" : "CFLAGS += -I. -Wall...",
                        "cyber-dojo.sh" : "make"
                     }
    }
```
- returns the id of the created practice session, eg
```
  { "kata_create": "A551C5"
  }
```

- - - -

## GET kata_manifest
Returns the manifest used to create the practice-session with the given id.
- parameter, eg
```
  { "id": "A551C5" }
```
- returns, eg
```
    { "kata_manifest": {
                        "id": "A551C5",
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
             "visible_files": {
                               "hiker.h": "#ifndef HIKER_INCLUDED...",
                               "hiker.c": "#include \"hiker.h\"...",
                        "hiker.tests.c" : "#include <assert.h>\n...",
                         "instructions" : "Write a program that...",
                             "makefile" : "CFLAGS += -I. -Wall...",
                        "cyber-dojo.sh" : "make"
                     }
      }
    }
```

- - - -

## GET kata_exists?
Asks whether the practice-session with the given id exists.
- parameters, eg
```
  { "id": "15B9AD" }
```
- returns true if it does, false if it doesn't, eg
```
  { "kata_exist?": true   }
  { "kata_exist?": false  }
```

- - - -

## POST kata_ran_tests
In the practice-session with the given id,
the given visible files were submitted as tag number n,
at the given time, which produced the given stdout, stderr, status,
with the given traffic-light colour.
- parameters, eg
```
  {      "id": "A551C5",
          "n": 3,
      "files": {       "hiker.h" : "ifndef HIKER_INCLUDED\n...",
                       "hiker.c" : "#include \"hiker.h\"...",
                 "hiker.tests.c" : "#include <assert.h>\n...",
                  "instructions" : "Write a program that...",
                      "makefile" : "CFLAGS += -I. -Wall...",
                 "cyber-dojo.sh" : "make"
               }
        "now": [2016,12,6, 12,31,15],
     "stdout": "",
     "stderr": "Assert failed: answer() == 42",
     "status": 23,
     "colour": "red"
  }
```
Returns tags, eg
```
  { "kata_ran_tests": [
      {  "event": "created", "time": [2016,12,5, 11,15,18], "number": 0 },
      { "colour": "red,      "time": [2016,12,6, 12,31,15], "number": 1 }
    ]
  }
```

- - - -

## GET kata_tags
Returns details of all traffic-lights, for the practice-session
with the given id.
- parameters, eg
```
  { "id": "A551C5" }
```
- returns, eg
```
  { "kata_tags": [
      {  "event": "created", "time": [2016,12,5, 11,15,18], "number": 0 },
      { "colour": "red,      "time": [2016,12,6, 12,31,15], "number": 1 },
      { "colour": "green",   "time": [2016,12,6, 12,32,56], "number": 2 },
      { "colour": "amber",   "time": [2016,12,6, 12,43,19], "number": 3 }
    ]
  }
```

- - - -

## GETkata_tag
Returns the files, stdout, stderr, status,
for the practice-session with the given id,
and the given tag number n.
- parameters, eg
```
  { "id": "A551C5",
     "n": 3
  }
```
- returns, eg
```
  { "kata_tag": {
           "files": {
              "hiker.h" : "ifndef HIKER_INCLUDED\n...",
              "hiker.c" : "#include \"hiker.h\"...",
        "hiker.tests.c" : "#include <assert.h>...",
         "instructions" : "Write a program that...",
             "makefile" : "CFLAGS += -I. -Wall...",
        "cyber-dojo.sh" : "make"
      },
      "stdout": "",
      "stderr": "Assert failed: answer() == 42",
      "status": 23,
    }
  }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)

