import sys

def get_sample_type(sample_name):
  """
  Sample format is:
  TestID/{CoPath}_{FirstFourLettersOfPatientLastName}_{Date}_{Machine}[_OptionalFatAspirateTag]_{Sample}.raw
  """
  no_raw = sample_name.split(".")
  parts = no_raw[0].split("_")
  print(parts)
  directory_parts = parts[0:-1]
  type = "Amyloid"
  tagged = False
  copath = parts[0]
  patient = parts[1]
  date = parts[2]
  machine = parts[3]
  tag = None
  if len(parts) == 6:
    tagged = True
    tag = parts[4]
    sample = parts[5]
  elif len(parts) == 5:
    tag = None
    sample = parts[4]
  
  if tagged:
    if tag == 'FGN':
      type = 'FGN'
    elif tag == 'RB':
      type = 'Fibronectin'
    elif tag == 'MGN':
      type = 'Membranous'
    else:
      type = 'UNKNOWN'
  
  return type
