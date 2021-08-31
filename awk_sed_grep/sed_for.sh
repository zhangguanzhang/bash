#!/bin/bash

cat > g
window.dLocale_time-range = time-range
feature-value = 1
 window.dLocale_feature-value = feature-value
 window.dLocale_feature-value-Aest =feature-value-Aest
 window.dLocale_feature-value-Best-Cest1 =3 _feature-value-Best-Cest1
 
find -type f -not -path '*/\.git/*' -exec sed -ri ':a;/window.dLocale_/s#(dLocale_[^ -]+)-(.)#\1\U\2#;ta' {} \; 

cat g
window.dLocale_timeRange = time-range
feature-value = 1
 window.dLocale_featureValue = feature-value
 window.dLocale_featureValueAest =feature-value-Aest
 window.dLocale_featureValueBestCest1 =3 _feature-value-Best-Cest1
