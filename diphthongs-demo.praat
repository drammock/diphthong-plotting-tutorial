#! /usr/bin/praat
# script to load paired WAV and textgrid files, and extract formant
# measurements. Assumes that audio files end with ".wav" and TextGrids end with
# ".TextGrid", and that the sequences ".wav" and ".TextGrid" do not occur
# earlier in the filename.  Also assumes that audio-textgrid pairs have the same
# filename (modulo their file extensions) and that there are no unpaired WAV or
# textgrid files in the source directories.


# where should I look for the WAV and TextGrid files?  If they're in the same
# folder, just assign the same folder name to both variables, and it should
# still work.  Do be sure to include the trailing slash though!
audio_dir$ = "./audio/"
textgrid_dir$ = "./textgrid/"

# get all the names of sound files and count them
audio_files = Create Strings as file list: "audio_list", audio_dir$ + "*.wav"
Sort
n_audio = Get number of strings

# get all the names of textGrid files and count them
textgrid_files = Create Strings as file list: "textgrid_list", textgrid_dir$ + "*.TextGrid"
Sort
n_textgrids = Get number of strings

# rough check to make sure there are no unpaired files
assert n_audio = n_textgrids

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
  # make sure the TextGrid and WAV have matching filenames
  assert (this_audio_file$ - ".wav") = (this_textgrid_file$ - ".TextGrid")
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
