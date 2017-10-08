#! /usr/bin/praat
# script to read in paired WAV and TextGrid files, and extract formant measurements

audio_dir$ = "./audio/"
textgrid_dir$ = "./textgrid/"

# get all the names of sound files and count them
audio_files = Create Strings as file list: "audio_list", audio_dir$ + "*.wav"
n_audio = Get number of strings

# get all the names of textGrid files and count them
textgrid_files = Create Strings as file list: "textgrid_list", textgrid_dir$ + "*.TextGrid"
n_textgrids = Get number of strings

# initialize output
writeInfoLine: "filename,ipa,pct,time,formant_number,formant_value"

for ix to n_audio
  # load audio
  selectObject: audio_files
  this_audio_file$ = Get string: ix
  this_audio = Read from file: audio_dir$ + this_audio_file$
  # load textgrid
  selectObject: textgrid_files
  this_textgrid_file$ = Get string: ix
  this_textgrid = Read from file: textgrid_dir$ + this_textgrid_file$
  # get relevant interval
  selectObject: this_textgrid
  ipa$ = Get label of interval: 1, 2
  t_start = Get starting point: 1, 2
  t_end = Get end point: 1, 2
  # measure formants from 5% to 95% at 5% intervals
  selectObject: this_audio
  formants = To Formant (burg)... 0 5 5500 0.025 50
  for t from 1 to 19
    this_t = t_start + (t_end - t_start) * 0.05 * t
    f1 = Get value at time... 1 this_t Hertz Linear
    f2 = Get value at time... 2 this_t Hertz Linear
    this_pct$ = string$(t * 5) + "%"
    first_three_columns$ = this_audio_file$ + "," + ipa$ + "," + this_pct$ + ","
    appendInfoLine: first_three_columns$ + string$(this_t) + ",1," + string$(f1)
    appendInfoLine: first_three_columns$ + string$(this_t) + ",2," + string$(f2)
  endfor
  removeObject: this_audio
  removeObject: this_textgrid
  removeObject: formants
endfor
