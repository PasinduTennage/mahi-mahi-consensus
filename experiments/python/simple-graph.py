import matplotlib.pyplot as plt


plt.figure(figsize=(5, 4))
plt.rcParams.update({'font.size': 14.30})
ax = plt.gca()
ax.grid()


# ax.set_xlim([0, 600])
# ax.set_ylim([0, 500])

w4_throughput = [1000,
                 4999.916667,
                 10000.33333,
                 20000.33333,
                 45546.66667,
                 57567.33333,
                 50976.66667]
w4_median = [275.608,
             105.7805,
             135.3175,
             177.1885,
             183.5315,
             425.023,
             1102.614]

w5_throughput = [999.9833333,
                 5000,
                 10000.16667,
                 20000,
                 49757.5,
                 67652.83333,
                 43150]
w5_median = [177.8515,
             125.093,
             149.05,
             357.2725,
             283.18,
             312.485,
             790.1965]

w6_throughput = [999.9833333,
                 4999.916667,
                 10000.16667,
                 20000.66667,
                 49702.5,
                 66917.5,
                 37838]
w6_median = [146.7775,
             160.429,
             207.3735,
             204.6425,
             332.8245,
             351.597,
             1286.135]

w7_throughput = [999.9833333,
                 4999.833333,
                 9999.333333,
                 20000.33333,
                 49615.83333,
                 51180.5,
                 36156.66667]
w7_median = [346.574,
             163.66,
             199.802,
             228.0175,
             374.567,
             443.595,
             1548.8415]

w8_throughput = [999.9833333,
                 5000.166667,
                 10000,
                 19996.33333,
                 49464.16667,
                 66802,
                 26286.66667]
w8_median = [297.2875,
             198.597,
             223.5075,
             266.923,
             507.876,
             576.813,
             1560.932]

l_1_throughput = [999.9833333,
                  5000,
                  10000.16667,
                  20000,
                  49757.5,
                  67652.83333,
                  43150,
                  27731.33333]
l_1_median = [177.8515,
              125.093,
              149.05,
              357.2725,
              283.18,
              312.485,
              790.1965,
              1595.538]

l_2_throughput = [999.9833333,
                  4999.833333,
                  10000,
                  20000,
                  49417.5,
                  42775.5,
                  49433.33333]
l_2_median = [163.7045,
              156.9705,
              185.5125,
              173.8215,
              528.1615,
              230.872,
              920.5335]

l_3_throughput = [999.9833333,
                  5000,
                  10000,
                  19999.66667,
                  49380,
                  35806.5,
                  48053.33333]
l_3_median = [187.7465,
              167.2675,
              185.5115,
              153.703,
              580.209,
              342.436,
              1349.617]

l_4_throughput = [1000.016667,
                  4999.916667,
                  10000,
                  19969.66667,
                  47930.83333,
                  53930.5,
                  43053.33333]
l_4_median = [278.451,
              243.218,
              146.523,
              272.365,
              282.8625,
              352.604,
              2531.017]

c_throughput = [1000,
                4999.166667,
                8376,
                19999.66667,
                49565,
                51856.5,
                54576.66667,
                20347.33333]
c_median = [202.299,
            166.7905,
            177.858,
            251.8715,
            406.4115,
            319.101,
            884.584,
            1819.993]

h_throughput = [999.9666667,
                4913.916667,
                10000.33333,
                19971.66667,
                9598.333333,
                5143.833333]
h_median = [143.8355,
            149.667,
            241.625,
            230.162,
            722.209,
            2115.28]


plt.plot(l_1_throughput, l_1_median, 'c*-', label="Mysticity")
plt.plot(c_throughput, c_median, 'b*-', label="Codial Miners")
# plt.plot(w6_throughput, w6_median, 'g*-', label="w=6")
# plt.plot(w7_throughput, w7_median, 'r*-', label="w=7")
# plt.plot(w8_throughput, w8_median, 'm*-', label="w=8")

plt.xlabel('Throughput (req/s)')
plt.ylabel('Median Latency (ms)')
plt.legend()
plt.savefig('codial.png', bbox_inches='tight', pad_inches=0)
plt.close()