﻿using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace PrimeCSharp.SieveRunners
{
    public class RawB2Sieve : ISieveRunner
    {
        public string Name => "RawB2";
        public string Description => "Raw data, bytes, 1 of 2";
        public int SieveSize { get; }
        public int ClearCount { get; set; }

        private readonly byte[] data;
        private const int dataBits = 8;
        private const int dataBitsShift = 3;
        private const int dataBitsMask = 7;

        public RawB2Sieve(int sieveSize)
        {
            SieveSize = sieveSize;

            data = GC.AllocateUninitializedArray<byte>((SieveSize >> (dataBitsShift + 1)) + 1, pinned: true);
            data.AsSpan().Fill(byte.MaxValue);
        }

        public void Run()
        {
            int factor = 3;
            int q = (int)Math.Sqrt(SieveSize);

            for (int f = factor; f <= q; f += 2)
            {
                if (GetBit(f))
                {
                    int increment = f * 2;

                    for (int num = f * f; num <= SieveSize; num += increment)
                    {
                        ClearBit(num);
                    }
                }
            }
        }

        public IEnumerable<int> GetFoundPrimes()
        {
            yield return 2;

            for (int num = 3; num <= SieveSize; num += 2)
            {
                if (GetBit(num))
                {
                    yield return num;
                }
            }
        }



        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private ref byte GetRawBits(int index)
        {
            return ref Unsafe.Add(ref MemoryMarshal.GetArrayDataReference(data), index);
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private bool GetBit(int number)
        {
            System.Diagnostics.Debug.Assert(number % 2 == 1);

            //int index = number >> (dataBitsShift + 1); 
            //int shift = ((number >> 1) & dataBitsMask);
            //byte mask = (byte)(1 << shift);

            //return (data[index] & mask) != 0;

            //return (data[number >> (dataBitsShift + 1)] & (byte)(1 << ((number >> 1) & dataBitsMask))) != 0;

            return (GetRawBits(number >> (dataBitsShift + 1)) & (byte)(1 << ((number >> 1) & dataBitsMask))) != 0;
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private void ClearBit(int number)
        {
            System.Diagnostics.Debug.Assert(number % 2 == 1);

            //int index = number >> (dataBitsShift + 1);
            //int shift = ((number >> 1) & dataBitsMask);
            //byte mask = (byte)~(1 << shift);

            //data[index] &= mask;

            //data[number >> (dataBitsShift + 1)] &= (byte)~(1 << ((number >> 1) & dataBitsMask));
            
            GetRawBits(number >> (dataBitsShift + 1)) &= (byte)~(1 << ((number >> 1) & dataBitsMask));
        }
    }
}
