#!/bin/sh
for file in $(find ./app/assets/stylesheets/ -name "*.css.scss")
do
    git mv $file `echo $file | sed s/\.css//`
done