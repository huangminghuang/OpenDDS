#!/usr/bin/env python

import os
import re
import shlex
import glob

all_requires = {
  '!OPENDDS_SAFETY_PROFILE':'NO_OPENDDS_SAFETY_PROFILE',
  '!DDS_NO_OBJECT_MODEL_PROFILE': 'OBJECT_MODEL_PROFILE',
  '!DDS_NO_PERSISTENCE_PROFILE':'PERSISTENCE_PROFILE',
  '!DDS_NO_OWNERSHIP_PROFILE':'OWNERSHIP_PROFILE',
  '!DDS_NO_MULTI_TOPIC': 'MULTI_TOPIC',
  '!DDS_NO_OWNERSHIP_KIND_EXCLUSIVE': 'OWNERSHIP_KIND_EXCLUSIVE',
  '!NO_BUILT_IN_TOPICS': 'BUILT_IN_TOPICS',
  '!DDS_NO_CONTENT_FILTERED_TOPIC': 'CONTENT_FILTERED_TOPIC',
  '!DDS_NO_QUERY_CONDITION': 'QUERY_CONDITION',
  '!DDS_NO_CONTENT_SUBSCRIPTION': 'CONTENT_SUBSCRIPTION',
  '!CORBA_E_COMPACT': '"NOT CORBA_E_COMPACT"',
  '!CORBA_E_MICRO' : '"NOT CORBA_E_MICRO"',
  '!MIN_CORBA': '"NOT MINIMUM_CORBA"',
  'OPENDDS_SAFETY_PROFILE': '"NOT NO_OPENDDS_SAFETY_PROFILE"',
  '!DDS_NO_ORBSVCS': '"TARGET TAO_Svc_Utils"',
  '!STATIC':'BUILD_SHARED_LIBS'
}

all_labels = {
  'TCP':'TCP',
  'IPV6':'IPV6',
  '!NO_SHMEM':'SHMEM',
  'DDS4CCM_OPENDDS':'DDS4CCM_OPENDDS',
  'RTPS':'RTPS',
  '!NO_MCAST':'MCAST',
  'RTPS':'RTPS',
  '!TARGET':'HOST',
  '!NO_DDS_TRANSPORT':'DDS_TRANSPORT'
}

add_test_text = """

add_dds_test({name}
  COMMAND {command}
)
"""

class TestCase:
  def __init__(self, test, configs):
    self.test = test
    self._requires = set([])
    self._labels = []
    dcps_min = True
    for conf in configs:
      if conf in all_requires:
        self._requires.add(all_requires[conf])
      elif conf in all_labels:
        self._labels.append(all_labels[conf])
      elif conf == '!DCPS_MIN':
        dcps_min = False
    if dcps_min:
      self._labels.append('DCPS_MIN')

    self.dir = os.path.dirname(test.split()[0])

  def name(self):
    return '"%s"' % self.test

  def cmake_list_file(self):
    return os.path.join(self.dir, 'CMakeLists.txt')

  def command(self):
    return self.test[len(self.dir)+1:]

  def requires(self):
    if len(self._requires):
      return "\n  REQUIRES " + ' '.join(list(self._requires))
    else:
      return ""

  def labels(self):
    if len(self._labels):
      return  "\n  LABELS " + ' '.join(self._labels)
    else:
      return ""

def rename_test(filename):
  dir = os.path.dirname(filename)
  for mpc_file in glob.glob(os.path.join(dir, "*.mpc")):
    regex_sub_file(mpc_file, r"(\s*exename\s*=\s*test)\s*$",r"\1er")

  for script in glob.glob(os.path.join(dir, "*.pl")):
    regex_sub_file(script, r"(\s*->create_process\(\)\s*=\s*test)\s*$",r"\1er")

testcases = {}
with open('bin/dcps_tests.lst') as f:
  for line in f:
    line=line.strip()
    if line.startswith("#") or len(line) == 0:
      continue
    tuple = line.split(':')
    if len(tuple) == 2:
      configs = [c.upper() for c in tuple[1].split()]
    else:
      configs = []
    case = TestCase(tuple[0], configs)
    testcases.setdefault(case.cmake_list_file(), []).append(case)

for filename, test_group in testcases.iteritems():
  test_group_requires = set.intersection(*[ case._requires for case in test_group ])
  if len(test_group_requires):
    for case in test_group:
      case._requires = case._requires - test_group_requires
  file_content = ""
  requires_written = False
  with open(filename, "r") as myfile:
    for line in myfile:
      match = re.match("^requires\(([^\)]+)\)",line)
      if match:
        new_requires = set.union(test_group_requires, shlex.split(match.group(1)))
        file_content += "requires(%s)\n" % " ".join(new_requires)
        requires_written = True
      elif not requires_written and line.startswith("add_ace") and len(test_group_requires):
        requires_written = True
        file_content += "requires(%s)\n\n" % " ".join(test_group_requires)
        file_content += line
      elif line.startswith("include(${DDS_ROOT}/cmake/AddDdsTest.cmake)"):
        break
      else:
        file_content += line

  file_content = file_content.strip()
  file_content += "\n\ninclude(${DDS_ROOT}/cmake/AddDdsTest.cmake)\n"
  file_content += "link_test_files_to_build_tree()\n"
  for case in test_group:
    file_content += add_test_text.format(
        name = case.name(),
        command = case.command() + case.requires() + case.labels()
      )
  with open(filename, "w") as myfile:
    myfile.write(file_content)
