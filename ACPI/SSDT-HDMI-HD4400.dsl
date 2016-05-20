/*
 * Intel ACPI Component Architecture
 * AML Disassembler version 20131218-64 [Jan  8 2014]
 * Copyright (c) 2000 - 2013 Intel Corporation
 * 
 * Disassembly of iASL6pnP8Q.aml, Fri May 20 19:30:34 2016
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x000004D7 (1239)
 *     Revision         0x01
 *     Checksum         0xF4
 *     OEM ID           "syscl"
 *     OEM Table ID     "am89hd44"
 *     OEM Revision     0x00003000 (12288)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20131218 (538120728)
 */
DefinitionBlock ("iASL6pnP8Q.aml", "SSDT", 1, "syscl", "am89hd44", 0x00003000)
{

    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.B0D3._ADR)
    External (_SB_.PCI0.GFX0._ADR)

    Method (XOSI, 1, NotSerialized)
    {
        Return (LEqual (Arg0, "Windows 2009"))
    }

    Scope (\_SB.PCI0)
    {
        Device (HDAU)
        {
            Name (_ADR, 0x00030000)  // _ADR: Address
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                Store (Zero, \_SB.PCI0.B0D3._ADR)
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg2, Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Return (Package (0x04)
                {
                    "hda-gfx", 
                    Buffer (0x0A)
                    {
                        "onboard-1"
                    }, 

                    "layout-id", 
                    Buffer (0x04)
                    {
                         0x03, 0x00, 0x00, 0x00
                    }
                })
            }
        }

        Name (GFX0._STA, Zero)  // _STA: Status
        Device (IGPU)
        {
            Name (_ADR, 0x00020000)  // _ADR: Address
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                Store (Zero, \_SB.PCI0.GFX0._ADR)
            }

            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg2, Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Return (Package (0x04)
                {
                    "AAPL,ig-platform-id", 
                    Buffer (0x04)
                    {
                         0x06, 0x00, 0x26, 0x0A
                    }, 

                    "hda-gfx", 
                    Buffer (0x0A)
                    {
                        "onboard-1"
                    }
                })
            }

            OperationRegion (RMPC, PCI_Config, 0x10, 0x04)
            Field (RMPC, AnyAcc, NoLock, Preserve)
            {
                BAR1,   32
            }

            Device (PNLF)
            {
                Name (_ADR, Zero)  // _ADR: Address
                Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
                Name (_CID, "backlight")  // _CID: Compatible ID
                Name (_UID, 0x0F)  // _UID: Unique ID
                Name (_STA, 0x0B)  // _STA: Status
                OperationRegion (BRIT, SystemMemory, And (^BAR1, 0xFFFFFFF0), 0x000E1184)
                Field (BRIT, AnyAcc, Lock, Preserve)
                {
                    Offset (0x48250), 
                    LEV2,   32, 
                    LEVL,   32, 
                    Offset (0x70040), 
                    P0BL,   32, 
                    Offset (0xC8250), 
                    LEVW,   32, 
                    LEVX,   32, 
                    Offset (0xE1180), 
                    PCHL,   32
                }

                Name (LMAX, 0x0AD9)
                Name (KMAX, 0x0AD9)
                Method (_INI, 0, NotSerialized)  // _INI: Initialize
                {
                    Store (0xC0000000, LEVW)
                    If (LNot (LMAX))
                    {
                        Store (ShiftRight (LEVX, 0x10), LMAX)
                    }

                    If (LNot (LMAX))
                    {
                        Store (KMAX, LMAX)
                    }

                    If (LNotEqual (LMAX, KMAX))
                    {
                        Store (Zero, Local0)
                        While (LLess (Local0, SizeOf (_BCL)))
                        {
                            Store (DerefOf (Index (_BCL, Local0)), Local1)
                            Divide (Multiply (Local1, LMAX), KMAX, , Local1)
                            Store (Local1, Index (_BCL, Local0))
                            Increment (Local0)
                        }

                        Divide (Multiply (XRGL, LMAX), KMAX, , XRGL)
                        Divide (Multiply (XRGH, LMAX), KMAX, , XRGH)
                    }

                    Store (ShiftRight (LEVX, 0x10), Local1)
                    If (LNotEqual (Local1, LMAX))
                    {
                        Store (And (LEVX, 0xFFFF), Local0)
                        If (LOr (LNot (Local0), LNot (Local1)))
                        {
                            Store (LMAX, Local0)
                            Store (LMAX, Local1)
                        }

                        Divide (Multiply (Local0, LMAX), Local1, , Local0)
                        Store (Or (Local0, ShiftLeft (LMAX, 0x10)), LEVX)
                    }
                }

                Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
                {
                    Store (Match (_BCL, MGE, Arg0, MTR, Zero, 0x02), Local0)
                    If (LEqual (Local0, Ones))
                    {
                        Subtract (SizeOf (_BCL), One, Local0)
                    }

                    Store (Or (DerefOf (Index (_BCL, Local0)), ShiftLeft (LMAX, 0x10
                        )), LEVX)
                }

                Method (_BQC, 0, NotSerialized)  // _BQC: Brightness Query Current
                {
                    Store (Match (_BCL, MGE, And (LEVX, 0xFFFF), MTR, Zero, 
                        0x02), Local0)
                    If (LEqual (Local0, Ones))
                    {
                        Subtract (SizeOf (_BCL), One, Local0)
                    }

                    Return (DerefOf (Index (_BCL, Local0)))
                }

                Method (XBCM, 1, NotSerialized)
                {
                    If (LGreater (Arg0, XRGH))
                    {
                        Store (XRGH, Arg0)
                    }

                    If (LAnd (Arg0, LLess (Arg0, XRGL)))
                    {
                        Store (XRGL, Arg0)
                    }

                    Store (Or (Arg0, ShiftLeft (LMAX, 0x10)), LEVX)
                }

                Method (XBQC, 0, NotSerialized)
                {
                    Store (And (LEVX, 0xFFFF), Local0)
                    If (LGreater (Local0, XRGH))
                    {
                        Store (XRGH, Local0)
                    }

                    If (LAnd (Local0, LLess (Local0, XRGL)))
                    {
                        Store (XRGL, Local0)
                    }

                    Return (Local0)
                }

                Name (XOPT, 0x02)
                Name (XRGL, 0x19)
                Name (XRGH, 0x0AD9)
                Name (_BCL, Package (0x43)  // _BCL: Brightness Control Levels
                {
                    0x0AD9, 
                    0x02EC, 
                    Zero, 
                    0x23, 
                    0x27, 
                    0x2C, 
                    0x32, 
                    0x3A, 
                    0x43, 
                    0x4D, 
                    0x58, 
                    0x65, 
                    0x73, 
                    0x82, 
                    0x93, 
                    0xA5, 
                    0xB8, 
                    0xCC, 
                    0xE2, 
                    0xF9, 
                    0x0111, 
                    0x012B, 
                    0x0146, 
                    0x0162, 
                    0x017F, 
                    0x019E, 
                    0x01BE, 
                    0x01DF, 
                    0x0202, 
                    0x0225, 
                    0x024B, 
                    0x0271, 
                    0x0299, 
                    0x02C2, 
                    0x02EC, 
                    0x0317, 
                    0x0344, 
                    0x0372, 
                    0x03A2, 
                    0x03D2, 
                    0x0404, 
                    0x0437, 
                    0x046C, 
                    0x04A2, 
                    0x04D9, 
                    0x0511, 
                    0x054B, 
                    0x0586, 
                    0x05C2, 
                    0x05FF, 
                    0x063E, 
                    0x067E, 
                    0x06C0, 
                    0x0702, 
                    0x0746, 
                    0x078B, 
                    0x07D2, 
                    0x081A, 
                    0x0863, 
                    0x08AD, 
                    0x08F8, 
                    0x0945, 
                    0x0994, 
                    0x09E3, 
                    0x0A34, 
                    0x0A86, 
                    0x0AD9
                })
            }
        }
    }

    Scope (_SB)
    {
        Device (LPCB)
        {
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg2, Zero))
                {
                    Return (Buffer (One)
                    {
                         0x03
                    })
                }

                Return (Package (0x02)
                {
                    "compatible", 
                    "pci8086,9c43"
                })
            }
        }
    }

    Store ("SSDT-HDMI-HD4400 github.com/syscl/Inspiron15-5547", Debug)
}

