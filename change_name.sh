#!/bin/sh
for file in $(find ./app/assets/stylesheets/ -name "*.css.sass")
do
    git mv $file `echo $file | sed s/\.css//`
done