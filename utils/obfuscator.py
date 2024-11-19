import struct
import sys

class ELFHeader:
    def __init__(self, data):
        self.e_ident = data[0:16]
        self.e_type, self.e_machine, self.e_version, self.e_entry, self.e_phoff, self.e_shoff, \
        self.e_flags, self.e_ehsize, self.e_phentsize, self.e_phnum, self.e_shentsize, \
        self.e_shnum, self.e_shstrndx = struct.unpack('<HHIQQQIHHHHHH', data[16:64])

class SectionHeader:
    def __init__(self, data):
        self.sh_name, self.sh_type, self.sh_flags, self.sh_addr, self.sh_offset, \
        self.sh_size, self.sh_link, self.sh_info, self.sh_addralign, self.sh_entsize = struct.unpack('<IIIIQQIIII', data)

def obfuscate_elf(input_file, output_file):
    with open(input_file, 'rb') as f:
        data = bytearray(f.read())

    # Read ELF header
    header = ELFHeader(data)

    # Modify entry point
    header.e_entry += 0x1000  # Shift entry point

    # Read section headers
    section_headers = []
    for i in range(header.e_shnum):
        offset = header.e_shoff + i * header.e_shentsize
        section_headers.append(SectionHeader(data[offset:offset + header.e_shentsize]))

    # Obfuscate section names and contents
    xor_key = 0xAA  # Example XOR key
    for i, sh in enumerate(section_headers):
        if i != header.e_shstrndx:  # Skip the section name string table
            sh.sh_name = 0  # Set name index to 0 (or any other non-descriptive value)

        # Modify section contents
        if sh.sh_size > 0:
            section_offset = sh.sh_offset
            for j in range(sh.sh_size):
                data[section_offset + j] ^= xor_key  # XOR each byte with the key

    # Write modified ELF header back to the output data
    struct.pack_into('<HHIQQQIHHHHHH', data, 16, header.e_type, header.e_machine, header.e_version,
                     header.e_entry, header.e_phoff, header.e_shoff, header.e_flags,
                     header.e_ehsize, header.e_phentsize, header.e_phnum,
                     header.e_shentsize, header.e_shnum, header.e_shstrndx)

    # Write modified section headers back to the output data
    for i, sh in enumerate(section_headers):
        offset = header.e_shoff + i * header.e_shentsize
        struct.pack_into('<IIIIQQIIII', data, offset, sh.sh_name, sh.sh_type, sh.sh_flags,
                         sh.sh_addr, sh.sh_offset, sh.sh_size, sh.sh_link,
                         sh.sh_info, sh.sh_addralign, sh.sh_entsize)

    # Write the obfuscated ELF to a new file
    with open(output_file, 'wb') as f:
        f.write(data)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python elf_obfuscator.py <input_file> <output_file>")
        sys.exit(1)

    obfuscate_elf(sys.argv[1], sys.argv[2])
    print("Obfuscation complete.")
