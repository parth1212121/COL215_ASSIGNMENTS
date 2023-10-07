import re
from pathlib import Path
import sys

files = Path('').glob('circuit.txt')


for filename in files:

    with open(filename, 'r') as fp:
        content = [line for line in (line.strip() for line in fp) if not line.startswith('//') and line]

files = Path('').glob('gate_delays.txt')

for filename in files:
    with open(filename, 'r') as fp:
        content.extend([line for line in (line.strip() for line in fp) if not line.startswith('//') and line])

data = {
    'input': [],
    'output': [],
    'timingsA': {},
    'connectionsA': {},
    'timingsB': {},
    'connectionsB': {},
    'delay': {}
}

try:
    for line in content:
        if line.startswith('PRIMARY_INPUTS'):
            for i in [s.strip() for s in line.split()][1:]:
                data['timingsA'][i] = 0
            data['input'].extend([s.strip() for s in line.split()][1:])

        if line.startswith('PRIMARY_OUTPUTS'):
            data['output'].extend([s.strip() for s in line.split()][1:])

        if any(x in line[:5] for x in ['NAND2', 'NOR2', 'INV', 'XOR2', 'AND2', 'OR2', 'XNOR2']):
            gate, *inputs = [s.strip() for s in line.split()]
            if(len(inputs) == 1):
                data['delay'][gate] = float(inputs[0])
            else:
                data['connectionsA'][inputs[-1]] = (gate, inputs[:-1])
                for i in inputs[:-1]:
                    if i not in data['connectionsB']:
                        data['connectionsB'][i] = []
                    data['connectionsB'][i].extend([(gate, inputs[-1])])

except Exception as e:
    print(e)
    exit(0)

files = Path('').glob('required_delays.txt')

for filename in files:
    with open(filename, 'r') as fp:
        content = [line for line in (line.strip() for line in fp) if not line.startswith('//') and line]

try:
    for line in content:
        output, delay = [s.strip() for s in line.split()]
        data['timingsB'][output] = float(delay)

except Exception as e:
    print(e)
    exit(0)

def calc_delayA(signal):
    if signal in data['timingsA']:
        return data['timingsA'][signal]
    else:
        delay = 0
        for ins in data['connectionsA'][signal][1]:
            delay = max(delay, calc_delayA(ins))
        delay+=data['delay'][data['connectionsA'][signal][0]]
        data['timingsA'][signal]=delay
        return delay

def calc_delayB(signal):
    if signal in data['timingsB']:
        return data['timingsB'][signal]
    else:
        delay = float('inf')
        for gate, ins in data['connectionsB'][signal]:
            delay = min(delay, calc_delayB(ins)-data['delay'][gate])
        data['timingsB'][signal]=delay
        return delay

if(sys.argv[0]=='A'):
    with open('output_delays.txt', 'w') as f:
        for signal in data['output']:
            ret = calc_delayA(signal)
            if(ret.is_integer()): ret = int(ret)
            f.write(signal + ' ' + str(ret) + '\n')
else:
    with open('input_delays.txt', 'w') as f:
        for signal in data['input']:
            ret = calc_delayB(signal)
            if(ret.is_integer()): ret = int(ret)
            f.write(signal + ' ' + str(ret) + '\n')

