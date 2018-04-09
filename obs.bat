set height=-5
set timezone=-3
sextant 4 %timezone% %height% 1 > tmp.sex
type obs.sex >> tmp.sex
copy tmp.sex obs.sex
del tmp.sex
sex
