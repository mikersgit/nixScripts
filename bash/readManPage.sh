#!/bin/bash
PAGE="${@}"
groff -man -Tascii ${PAGE}
