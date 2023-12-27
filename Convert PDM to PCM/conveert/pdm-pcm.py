import numpy as np
import bitstring

def pdm_to_pcm(input_pdm_file, output_pcm_file, order='msb'):
    # Read PDM file
    with open(input_pdm_file, 'rb') as pdm_file:
        pdm_data = bitstring.BitArray(bytes=pdm_file.read()).bin

    # Convert PDM to PCM
    if order == 'lsb':
        pdm_data = pdm_data[::-1]

    pcm_data = np.zeros(len(pdm_data) // 2, dtype=np.int16)
    for i in range(0, len(pdm_data), 2):
        pcm_data[i // 2] = pdm_data[i:i + 2].count('1') - pdm_data[i:i + 2].count('0')

    # Write PCM file
    pcm_data.tofile(output_pcm_file)

if __name__ == "__main__":
    input_pdm_file = "input.pdm"
    output_pcm_file = "output.pcm"

    pdm_to_pcm(input_pdm_file, output_pcm_file)
