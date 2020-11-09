#!/usr/bin/env python3
with open('area_report.txt', 'r') as fp:
  lines= fp.readlines()
  lines= [l.strip() for l in lines]
  lines= [l.split() for l in lines]
  lines= [int(l[-1]) for l in lines if l]
  total_area= sum(lines)
  print(f'\nTotal area: {total_area}')
