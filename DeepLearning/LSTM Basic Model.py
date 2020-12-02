#!/usr/bin/env python
# coding: utf-8

# In[27]:


import pandas as pd


# In[32]:


import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

tf.reset_default_graph()
tf.set_random_seed(777) # reproducibility


# In[33]:


# 정규화 
def MinMaxScaler(data):
    numerator = data - np.min(data, 0)
    denominator = np.max(data, 0) - np.min(data, 0)
    # noise term prevents the zero division
    return numerator / (denominator + 1e-7)

# train Parameters
seq_length = 7
data_dim = 5
hidden_dim = 10
output_dim = 2
learning_rate = 0.01
iterations = 50

# Open, High, Low, Volume, Close
xy = np.loadtxt('data-02-stock_daily.csv', delimiter=',')
xy = xy[::-1] # reverse order (chronically ordered)
xy = MinMaxScaler(xy)
x = xy
y = xy[:, [-1]]  # 마지막 열이 주식 종가 


# In[36]:


# build a dataset
dataX = []
dataY = []
for i in range(0, len(y) - seq_length - 1):
    _x = x[i:i + seq_length]
    _y = np.array(y[(i + seq_length):(i + seq_length + 2)].flatten()) # Next close price

    print(_x, "->", _y)
    dataX.append(_x)
    dataY.append(_y)
    
# train/test split
train_size = int(len(dataY) * 0.7)
test_size = len(dataY) - train_size

trainX, testX = np.array(dataX[0:train_size]), np.array(dataX[train_size:len(dataX)])
trainY, testY = np.array(dataY[0:train_size]), np.array(dataY[train_size:len(dataY)])


# In[38]:


# input place holders
X = tf.placeholder(tf.float32, [None, seq_length, data_dim])
Y = tf.placeholder(tf.float32, [None, 2])  # output_dim 수 = 2

# build a LSTM network
# cell = tf.contrib.rnn.BasicRNNCell(num_units=hidden_dim, activation=tf.tanh)
# cell = tf.contrib.rnn.GRUCell(num_units=hidden_dim, activation=tf.tanh)
cell = tf.contrib.rnn.BasicLSTMCell(num_units=hidden_dim, activation=tf.tanh)

outputs, states = tf.nn.dynamic_rnn(cell, X, dtype=tf.float32)


# In[39]:


# many-to-one 모델 
Y_pred = tf.contrib.layers.fully_connected(outputs[:, -1], output_dim, activation_fn=None)


# In[40]:


# cost/loss
loss = tf.reduce_sum(tf.square(Y_pred - Y)) # sum of the squares
# optimizer
optimizer = tf.train.AdamOptimizer(learning_rate)
train = optimizer.minimize(loss)

# RMSE
targets = tf.placeholder(tf.float32, [None, 2])
predictions = tf.placeholder(tf.float32, [None, 2])
rmse = tf.sqrt(tf.reduce_mean(tf.square(targets - predictions)))


# In[41]:


with tf.Session() as sess:
    sess.run(tf.global_variables_initializer())
    # Training step
    for i in range(iterations):
        _, step_loss = sess.run([train, loss], feed_dict={X: trainX, Y: trainY})
        print("[step: {}] loss: {}".format(i, step_loss))
        # Test step
        test_predict = sess.run(Y_pred, feed_dict={X: testX})
        rmse_val = sess.run(rmse, feed_dict={targets: testY, predictions: test_predict})
        print("RMSE: {}".format(rmse_val))
        # Plot predictions
    plt.plot(testY)
    plt.plot(test_predict)
    plt.xlabel("Time Period")
    plt.ylabel("Stock Price")
    plt.show()


# In[42]:


test_predict

