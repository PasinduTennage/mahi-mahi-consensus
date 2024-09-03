narwhal_50_best_throughput = []
narwhal_50_best_latency = []
narwhal_50_best_std = []

narwhal_10_best_throughput = []
narwhal_10_best_latency = []
narwhal_10_best_std = []

narwhal_10_crash_throughput = []
narwhal_10_crash_latency = []
narwhal_10_crash_std = []

cm_50_best_throughput = []
cm_50_best_latency = []
cm_50_best_std = []

cm_10_best_throughput = []
cm_10_best_latency = []
cm_10_best_std = []

cm_10_crash_throughput = []
cm_10_crash_latency = []
cm_10_crash_std = []

mm_50_best_throughput = []
mm_50_best_latency = []
mm_50_best_std = []

mm_w5_l1_10_best_throughput = []
mm_w5_l1_10_best_latency = []
mm_w5_l1_10_best_std = []

mm_w5_l1_10_crash_throughput = []
mm_w5_l1_10_crash_latency = []
mm_w5_l1_10_crash_std = []

mm_w5_l2_10_best_throughput = []
mm_w5_l2_10_best_latency = []
mm_w5_l2_10_best_std = []

mm_w5_l2_10_crash_throughput = []
mm_w5_l2_10_crash_latency = []
mm_w5_l2_10_crash_std = []

mm_w4_l1_10_best_throughput = []
mm_w4_l1_10_best_latency = []
mm_w4_l1_10_best_std = []

mm_w4_l1_10_crash_throughput = []
mm_w4_l1_10_crash_latency = []
mm_w4_l1_10_crash_std = []

# checked names above sept 3 - 18,21


import matplotlib.pyplot as plt

# 'g': mahi-mahi
# 'r': codial-miners
# 'c': nawrhal

# -   50 nodes
# --  10 nodes

# figure 1 - best case
plt.figure(figsize=(10, 4))
plt.rcParams.update({'font.size': 14.30})
ax = plt.gca()

# ax.set_xlim([0, 1500])
# ax.set_ylim([900, 2000])

plt.plot(narwhal_50_best_throughput, narwhal_50_best_latency, 'c-', label='Narwhal-50')
plt.errorbar(narwhal_50_best_throughput, narwhal_50_best_latency, yerr=narwhal_50_best_std, fmt='o', ecolor='c', capsize=5)

plt.plot(cm_50_best_throughput, cm_50_best_latency, 'r-', label='Cordial Miners-50')
plt.errorbar(cm_50_best_throughput, cm_50_best_latency, yerr=cm_50_best_std, fmt='o', ecolor='r', capsize=5)

plt.plot(mm_50_best_throughput, mm_50_best_latency, 'g-', label='Mahi-Mahi-50')
plt.errorbar(mm_50_best_throughput, mm_50_best_latency, yerr=mm_50_best_std, fmt='o', ecolor='g', capsize=5)

plt.plot(narwhal_10_best_throughput, narwhal_10_best_latency, 'c--', label='Narwhal-10')
plt.errorbar(narwhal_10_best_throughput, narwhal_10_best_latency, yerr=narwhal_10_best_std, fmt='o', ecolor='c', capsize=5)

plt.plot(cm_10_best_throughput, cm_10_best_latency, 'r--', label='Cordial Miners-10')
plt.errorbar(cm_10_best_throughput, cm_10_best_latency, yerr=cm_10_best_std, fmt='o', ecolor='r', capsize=5)

plt.plot(mm_w5_l1_10_best_throughput, mm_w5_l1_10_best_latency, 'g--', label='Mahi-Mahi-10')
plt.errorbar(mm_w5_l1_10_best_throughput, mm_w5_l1_10_best_latency, yerr=mm_w5_l1_10_best_std, fmt='o', ecolor='g', capsize=5)


plt.xlabel('Throughput (req/s)')
plt.ylabel('Average Latency (ms)')
plt.grid()
plt.legend()
plt.savefig('best-case.png', bbox_inches='tight', pad_inches=0)
plt.close()

# figure 2 - crash case
plt.figure(figsize=(5, 4))
plt.rcParams.update({'font.size': 14.30})
ax = plt.gca()

# ax.set_xlim([0, 1500])
# ax.set_ylim([900, 2000])


plt.plot(narwhal_10_crash_throughput, narwhal_10_crash_latency, 'c-', label='Narwhal-10')
plt.errorbar(narwhal_10_crash_throughput, narwhal_10_crash_latency, yerr=narwhal_10_crash_std, fmt='o', ecolor='c', capsize=5)

plt.plot(cm_10_crash_throughput, cm_10_crash_latency, 'r-', label='Cordial Miners-10')
plt.errorbar(cm_10_crash_throughput, cm_10_crash_latency, yerr=cm_10_crash_std, fmt='o', ecolor='r', capsize=5)

plt.plot(mm_w5_l1_10_crash_throughput, mm_w5_l1_10_crash_latency, 'g-', label='Mahi-Mahi-10')
plt.errorbar(mm_w5_l1_10_crash_throughput, mm_w5_l1_10_crash_latency, yerr=mm_w5_l1_10_crash_std, fmt='o', ecolor='g', capsize=5)


plt.xlabel('Throughput (req/s)')
plt.ylabel('Average Latency (ms)')
plt.grid()
plt.legend()
plt.savefig('crash.png', bbox_inches='tight', pad_inches=0)
plt.close()

# figure 3 - leaders
plt.figure(figsize=(5, 4))
plt.rcParams.update({'font.size': 14.30})
ax = plt.gca()

# ax.set_xlim([0, 1500])
# ax.set_ylim([900, 2000])


plt.plot(mm_w5_l1_10_best_throughput, mm_w5_l1_10_best_latency, 'g-', label='Mahi-Mahi-l1')
plt.errorbar(mm_w5_l1_10_best_throughput, mm_w5_l1_10_best_latency, yerr=mm_w5_l1_10_best_std, fmt='o', ecolor='g', capsize=5)

plt.plot(mm_w5_l2_10_best_throughput, mm_w5_l2_10_best_latency, 'r-', label='Mahi-Mahi-l2')
plt.errorbar(mm_w5_l2_10_best_throughput, mm_w5_l2_10_best_latency, yerr=mm_w5_l2_10_best_std, fmt='o', ecolor='r', capsize=5)

plt.plot(mm_w5_l1_10_crash_throughput, mm_w5_l1_10_crash_latency, 'g--', label='Mahi-Mahi-l1-crash')
plt.errorbar(mm_w5_l1_10_crash_throughput, mm_w5_l1_10_crash_latency, yerr=mm_w5_l1_10_crash_std, fmt='o', ecolor='g', capsize=5)

plt.plot(mm_w5_l2_10_crash_throughput, mm_w5_l2_10_crash_latency, 'r--', label='Mahi-Mahi-l2-crash')
plt.errorbar(mm_w5_l2_10_crash_throughput, mm_w5_l2_10_crash_latency, yerr=mm_w5_l2_10_crash_std, fmt='o', ecolor='r', capsize=5)


plt.xlabel('Throughput (req/s)')
plt.ylabel('Average Latency (ms)')
plt.grid()
plt.legend()
plt.savefig('leaders.png', bbox_inches='tight', pad_inches=0)
plt.close()

# figure 4 - wave length
plt.figure(figsize=(5, 4))
plt.rcParams.update({'font.size': 14.30})
ax = plt.gca()

# ax.set_xlim([0, 1500])
# ax.set_ylim([900, 2000])


plt.plot(mm_w5_l1_10_best_throughput, mm_w5_l1_10_best_latency, 'g-', label='Mahi-Mahi-w5')
plt.errorbar(mm_w5_l1_10_best_throughput, mm_w5_l1_10_best_latency, yerr=mm_w5_l1_10_best_std, fmt='o', ecolor='g', capsize=5)

plt.plot(mm_w4_l1_10_best_throughput, mm_w4_l1_10_best_latency, 'r-', label='Mahi-Mahi-w4')
plt.errorbar(mm_w4_l1_10_best_throughput, mm_w4_l1_10_best_latency, yerr=mm_w4_l1_10_best_std, fmt='o', ecolor='r', capsize=5)

plt.plot(mm_w5_l1_10_crash_throughput, mm_w5_l1_10_crash_latency, 'g--', label='Mahi-Mahi-w5-crash')
plt.errorbar(mm_w5_l1_10_crash_throughput, mm_w5_l1_10_crash_latency, yerr=mm_w5_l1_10_crash_std, fmt='o', ecolor='g', capsize=5)

plt.plot(mm_w4_l1_10_crash_throughput, mm_w4_l1_10_crash_latency, 'r--', label='Mahi-Mahi-w4-crash')
plt.errorbar(mm_w4_l1_10_crash_throughput, mm_w4_l1_10_crash_latency, yerr=mm_w4_l1_10_crash_std, fmt='o', ecolor='r', capsize=5)


plt.xlabel('Throughput (req/s)')
plt.ylabel('Average Latency (ms)')
plt.grid()
plt.legend()
plt.savefig('waves.png', bbox_inches='tight', pad_inches=0)
plt.close()
