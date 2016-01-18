#!/bin/bash

source $NVM_DIR/nvm.sh
nvm use 0.11

FILES="jquery.autocomplete jquery.captcha jquery.cookie jquery.expander jquery.gmap_directions jquery.gmaps jquery.images_gallery jquery.location_comparison jquery.location_images jquery.location_rating jquery.main jquery.MetaData jquery.scroll_to jquery.socialshareprivacy"
DIR="public/javascripts/frontend"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done

FILES="jquery.showLoading"
DIR="public/javascripts/frontend/show_loading/js"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done

FILES="jquery.ad-gallery"
DIR="public/javascripts/frontend/ad_gallery"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done

FILES="jssor jssor.slider jssor.full_width_slider"
DIR="public/javascripts/frontend/jssor_slider"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done

FILES="bootstrap_overrides"
DIR="public/javascripts/mobile"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done

FILES="more_less_links jquery.addthis_smart_layers"
DIR="public/javascripts/shared"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done

FILES="string window.location"
DIR="public/javascripts/shared/extensions"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.js > $DIR/$file.min.js"
  minify $DIR/$file.js > $DIR/$file.min.js
done















FILES="bootstrap_overrides classes css3_formular_style global images jquery-ui-autocomplete jquery.fancybox-1.3.4 jquery.rating layout page print responsive socialshareprivacy styles"
DIR="public/stylesheets/frontend"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.css > $DIR/$file.min.css"
  minify $DIR/$file.css > $DIR/$file.min.css
done

FILES="showLoading"
DIR="public/javascripts/frontend/show_loading/css"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.css > $DIR/$file.min.css"
  minify $DIR/$file.css > $DIR/$file.min.css
done

FILES="jquery.ad-gallery"
DIR="public/javascripts/frontend/ad_gallery"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.css > $DIR/$file.min.css"
  minify $DIR/$file.css > $DIR/$file.min.css
done


FILES="bootstrap_overrides global"
DIR="public/stylesheets/mobile"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.css > $DIR/$file.min.css"
  minify $DIR/$file.css > $DIR/$file.min.css
done

FILES="jquery.flex-images"
DIR="public/javascripts/mobile/flex_images"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.css > $DIR/$file.min.css"
  minify $DIR/$file.css > $DIR/$file.min.css
done

FILES="addthis_smart_layers common"
DIR="public/stylesheets/shared"
IFS=' ' read -a files_split <<< "${FILES}"
for file in ${files_split[@]}
do
  echo "minify $DIR/$file.css > $DIR/$file.min.css"
  minify $DIR/$file.css > $DIR/$file.min.css
done
