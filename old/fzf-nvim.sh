#!/bin/bash

selected=$(fzf)

[ -n "$selected" ] && nvim "$selected" 
