#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (C) 2017 Jayant Jain <jayantjain1992@gmail.com>
# Licensed under the GNU LGPL v2.1 - http://www.gnu.org/licenses/lgpl.html

"""
Testing fast counting approaches
"""
from libcpp.unordered_map cimport unordered_map
from collections import defaultdict

class CounterCython(object):

    def __init__(self):
        self.counts = {}

    def update(self, items):
        for item in items:
            try:
                self.counts[item] += 1
            except KeyError:
                self.counts[item] = 1

    def update_sents(self, sents):
        for sent in sents:
            self.update(sent)

    def get(self, key):
        return self[key]

    def __getitem__(self, key):
        return self.counts[key]


class CounterCythonDefaultDict(object):
    def __init__(self):
        self.counts = defaultdict(int)

    def update(self, items):
        for item in items:
            self.counts[item] += 1

    def update_sents(self, sents):
        for sent in sents:
            self.update(sent)

    def get(self, key):
        return self[key]

    def __getitem__(self, key):
        if key in self.counts:
            return self.counts[key]
        else:
            raise KeyError('key %s not present in counts' % key)


class CounterCythonUnorderedMap(object):

    def __init__(self):
        self.counts = {}

    def update(self, items):
        cdef unordered_map[long, int] counts = self.counts
        for item in items:
            hashed_item = hash(item)
            if counts.count(hashed_item) == 1:
                counts[hashed_item] += 1
            else:
                counts[hashed_item] = 1
        self.counts = counts

    def update_sents(self, sents):
        cdef unordered_map[long, int] counts = self.counts
        for sent in sents:
            for item in sent:
                hashed_item = hash(item)
                if counts.count(hashed_item) == 1:
                    counts[hashed_item] += 1
                else:
                    counts[hashed_item] = 1
        self.counts = counts

    def get(self, key):
        return self[key]

    def __getitem__(self, key):
        return self.counts[hash(key)]
