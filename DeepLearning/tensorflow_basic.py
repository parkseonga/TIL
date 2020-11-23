 0# -*- coding: utf-8 -*-
"""
Created on Thu Sep 10 13:42:58 2020

@author: a0105
"""

import tensorflow.compat.v1 as tf

tf.disable_v2_behavior()

a = tf.constant(1)
b = tf.constant(2)
c = tf.add(a,b)

print(c)

sess = tf.Session()
print(sess.run([a, b, c]))

tf.print(a,b,c)

sess.close()

# 2

a = tf.placeholder(tf.float32)
b = tf.placeholder(tf.float32)

adder_node = a + b

sess = tf.Session()

print(sess.run(adder_none, feed_dict = {a:3, b:4.5}))
print(sess.run(adder_none, feed_dict = {a:[1,3], b: [2,4]}))


# 3
import tensorflow as tf

hello = tf.constant('Hello, Tensorflow!')

sess = tf.Session()
print(sess.run(hello))
sess.close()

# 4
X = [1, 2, 3]
Y = [1, 2, 3]

W = tf.Variable(tf.random_normal([1]), name ='weight')
b = tf.Variable(tf.random_normal([1]), name ='bias')

hypothesis = X * w + b