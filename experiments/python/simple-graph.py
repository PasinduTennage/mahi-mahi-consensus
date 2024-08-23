import matplotlib.pyplot as plt


plt.figure(figsize=(5, 4))
plt.rcParams.update({'font.size': 14.30})
ax = plt.gca()
ax.grid()


# ax.set_xlim([0, 1500])
ax.set_ylim([900, 2000])

c_throughput = [999.9666667,
                5000,
                19999.66667,
                50000.83333,
                100003.3333,
                109998.1667,
                129995.6667,
                150012.5,
                159989.3333]
c_median = [1310.063,
            1310.517,
            1325.447,
            1358.304,
            1411.438,
            1410.974,
            1443.461,
            1552.226,
            9925.951]

w4_throughput = [1000.016667,
                 4999.833333,
                 20000,
                 49998.33333,
                 100011.6667,
                 110016.5,
                 129997.8333,
                 150002.5]
w4_median = [1291.31,
             1017.541,
             1215.68,
             1137.609,
             1233.864,
             1173.7375,
             1188.4165,
             1155.809]

w5_throughput = [999.9833333,
                 5000,
                 19999.66667,
                 50003.33333,
                 100005,
                 110005.5,
                 129997.8333,
                 149992.5,
                 178856.6667]
w5_median = [1000.8515,
             1017.017,
             1001.9685,
             1025.115,
             1080.233,
             1087.0685,
             1117.2635,
             1233.638,
             23046.3575]

w6_throughput = [1000.016667,
                 5000,
                 19999.66667,
                 49996.66667,
                 99998.33333,
                 110003.6667,
                 129995.6667,
                 150000]
w6_median = [1151.4725,
             1152.103,
             1145.719,
             1204.974,
             1256.232,
             1256.3855,
             1284.4635,
             1440.524]


l_2_throughput = [1000.016667,
                  5000.083333,
                  20000,
                  50001.66667,
                  100003.3333,
                  110001.8333,
                  130002.1667,
                  150005]
l_2_median = [966.551,
              991.654,
              964.958,
              1016.0355,
              1067.934,
              1089.5475,
              1105.69,
              1179.6985]

l_3_throughput = [1000.016667,
                  5000,
                  20000,
                  49995.83333,
                  99998.33333,
                  110001.8333,
                  129993.5,
                  149997.5]
l_3_median = [973.3915,
              941.076,
              979.02,
              972.785,
              1044.813,
              1060.69,
              1088.8085,
              1163.5005]


# plt.plot(w5_throughput, w5_median, 'c*-', label="Mysticity(w5-l1)")
# plt.plot(c_throughput, c_median, 'b*-', label="Codial Miners")
# plt.plot(w4_throughput, w4_median, 'g*-', label="Mysticity(w4-l1)")
# plt.plot(w6_throughput, w6_median, 'r*-', label="Mysticity(w6-l1)")

plt.plot(w5_throughput, w5_median, 'g*-', label="Mysticity(w5-l1)")
plt.plot(l_2_throughput, l_2_median, 'c*-', label="Mysticity(w5-l2)")
plt.plot(l_3_throughput, l_3_median, 'b*-', label="Mysticity(w5-l3)")
plt.plot(c_throughput, c_median, 'r*-', label="Codial Miners")

plt.xlabel('Throughput (req/s)')
plt.ylabel('Median Latency (ms)')
plt.legend()
plt.savefig('leaders.png', bbox_inches='tight', pad_inches=0)
plt.close()