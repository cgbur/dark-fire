# Run from the repository root:
# nix develop --command gnuplot docs/assets/background-lightness.gnuplot
#
# CIE L* is calculated from each neutral sRGB background's relative luminance.
# OKLab L is the lightness coordinate used by the palette generator.

set terminal pngcairo size 1700,1000 enhanced font "DejaVu Sans,18" background rgb "#161616"
set output "docs/assets/background-lightness.png"

set title "Dark Fire background lightness" font ",29" textcolor rgb "#EFEFE7" offset 0,1.3
set label 100 "CIE L* is the practical spacing guide; OKLab L × 100 is the generator's current lightness coordinate." at screen 0.5,0.815 center font ",15" textcolor rgb "#B7D4EB"
set xlabel "Generated background color" offset 0,-1.7 textcolor rgb "#EFEFE7"
set ylabel "Perceptual lightness score (0 = black)" offset -1.4,0 textcolor rgb "#EFEFE7"

set xrange [-0.35:7.35]
set yrange [-1:45]
set xtics ( \
    "Original\n#404040" 0, \
    "Original\nhigh contrast\n#383838" 1, \
    "Stealth\n#262626" 2, \
    "Dark\n#1C1C1C" 3, \
    "Darker\n#161616" 4, \
    "Deep dark\n#0E0E0E" 5, \
    "Near black\n#070707" 6, \
    "Full black\n#000000" 7 \
) nomirror scale 0 font ",15" textcolor rgb "#EFEFE7"
set ytics 5 nomirror textcolor rgb "#EFEFE7"
set grid ytics linewidth 1 linecolor rgb "#323232"
set border 3 linewidth 1.5 linecolor rgb "#626262"
set key at graph 0.98,0.68 right top vertical Left reverse width 1.5 spacing 1.3 box opaque font ",15" textcolor rgb "#EFEFE7"
set lmargin 11
set rmargin 4
set bmargin 7
set tmargin 8

set object 1 rect from first -0.24,40.5 to first 0.24,42.8 fc rgb "#404040" fs solid 1.0 border lc rgb "#626262"
set object 2 rect from first 0.76,40.5 to first 1.24,42.8 fc rgb "#383838" fs solid 1.0 border lc rgb "#626262"
set object 3 rect from first 1.76,40.5 to first 2.24,42.8 fc rgb "#262626" fs solid 1.0 border lc rgb "#626262"
set object 4 rect from first 2.76,40.5 to first 3.24,42.8 fc rgb "#1C1C1C" fs solid 1.0 border lc rgb "#626262"
set object 5 rect from first 3.76,40.5 to first 4.24,42.8 fc rgb "#161616" fs solid 1.0 border lc rgb "#626262"
set object 6 rect from first 4.76,40.5 to first 5.24,42.8 fc rgb "#0E0E0E" fs solid 1.0 border lc rgb "#626262"
set object 7 rect from first 5.76,40.5 to first 6.24,42.8 fc rgb "#070707" fs solid 1.0 border lc rgb "#626262"
set object 8 rect from first 6.76,40.5 to first 7.24,42.8 fc rgb "#000000" fs solid 1.0 border lc rgb "#626262"

set label 1 "actual backgrounds" at -0.24,44.25 left font ",13" textcolor rgb "#EFEFE7"
plot '-' using 1:2 with linespoints linewidth 4 pointtype 7 pointsize 1.25 linecolor rgb "#DF9D6F" title "CIE L* (recommended)", \
     '-' using 1:2 with linespoints linewidth 3 pointtype 5 pointsize 1.2 dashtype 2 linecolor rgb "#74B5E8" title "OKLab L × 100", \
     '-' using 1:(-0.6) with points pointtype 9 pointsize 1.25 linewidth 2 linecolor rgb "#E2D082" title "added in this repo"
0 27.093
1 23.521
2 15.160
3 10.268
4 7.247
5 3.967
6 1.919
7 0.000
e
0 37.149
1 34.070
2 26.862
3 22.645
4 20.019
5 16.376
6 12.856
7 0.000
e
3
5
6
7
e
