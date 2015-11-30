#!/bin/bash

#exiftool -d %Y%m%d_%H%M%%-c.%%e "-filename<CreateDate" DIR
#www.sno.phy.queensu.ca

#Test rename but keep original filename:
#exiftool -d %Y%m%d_%H%M%S[%f]%%-c.%%e "-testname<CreateDate" Camera/
#exiftool -d %Y-%m/%Y%m%d_%H%M%S[%f]%%-c.%%e "-testname<CreateDate" Camera/
exiftool -d %Y-%m/%Y.%m.%d-%H%M%S.[%f]%%-c.%%e "-testname<CreateDate" Camera/
