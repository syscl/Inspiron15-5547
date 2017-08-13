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
    
    Name (SRCB, 0xFED1C000)

    OperationRegion (GNVS, SystemMemory, 0x9AFBBA98, 0x000002E9)
    Field (GNVS, AnyAcc, Lock, Preserve)
    {
        OSYS,   16, 
    }

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
                         0x1B, 0x00, 0x00, 0x00
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
            OperationRegion (RMPC, PCI_Config, 0x10, 4)
            Field (RMPC, AnyAcc, NoLock, Preserve)
            {
                BAR1,32,
            }
            Device (PNLF)
            {
                // normal PNLF declares (note some of this probably not necessary)
                Name (_ADR, Zero)
                Name (_HID, EisaId ("APP0002"))
                Name (_CID, "backlight")
                Name (_UID, 15)
                Name (_STA, 0x0B)
                // define hardware register access for brightness
                // lower nibble of BAR1 is status bits and not part of the address
                OperationRegion (BRIT, SystemMemory, And(^BAR1, Not(0xF)), 0xe1184)
                Field (BRIT, AnyAcc, Lock, Preserve)
                {
                    Offset(0x48250),
                    LEV2, 32,
                    LEVL, 32,
                    Offset(0x70040),
                    P0BL, 32,
                    Offset(0xc8250),
                    LEVW, 32,
                    LEVX, 32,
                    Offset(0xe1180),
                    PCHL, 32,
                }
                // LMAX: use 0xad9/0x56c/0x5db to force OS X value
                //       or use any arbitrary value
                //       or use 0 to capture BIOS setting
                Name (LMAX, 0xad9)
                // KMAX: defines the unscaled range in the _BCL table below
                Name (KMAX, 0xad9)
                // _INI deals with differences between native setting and desired
                Method (_INI, 0, NotSerialized)
                {
                    // This 0xC value comes from looking what OS X initializes this
                    // register to after display sleep (using ACPIDebug/ACPIPoller)
                    Store(0xC0000000, LEVW)
                    // determine LMAX to use
                    If (LNot(LMAX)) { Store(ShiftRight(LEVX,16), LMAX) }
                    If (LNot(LMAX)) { Store(KMAX, LMAX) }
                    If (LNotEqual(LMAX, KMAX))
                    {
                        // Scale all the values in _BCL to the PWM max in use
                        Store(0, Local0)
                        While (LLess(Local0, SizeOf(_BCL)))
                        {
                            Store(DerefOf(Index(_BCL,Local0)), Local1)
                            Divide(Multiply(Local1,LMAX), KMAX,, Local1)
                            Store(Local1, Index(_BCL,Local0))
                            Increment(Local0)
                        }
                        // Also scale XRGL and XRGH values
                        Divide(Multiply(XRGL,LMAX), KMAX,, XRGL)
                        Divide(Multiply(XRGH,LMAX), KMAX,, XRGH)
                    }
                    // adjust values to desired LMAX
                    Store(ShiftRight(LEVX,16), Local1)
                    If (LNotEqual(Local1, LMAX))
                    {
                        Store(And(LEVX,0xFFFF), Local0)
                        If (LOr(LNot(Local0),LNot(Local1))) { Store(LMAX, Local0) Store(LMAX, Local1) }
                        Divide(Multiply(Local0,LMAX), Local1,, Local0)
                        //REVIEW: wait for vblank before setting new PWM config
                        //Store(P0BL, Local7)
                        //While (LEqual (P0BL, Local7)) {}
                        Store(Or(Local0,ShiftLeft(LMAX,16)), LEVX)
                    }
                }
                // _BCM/_BQC: set/get for brightness level
                Method (_BCM, 1, NotSerialized)
                {
                    // store new backlight level
                    Store(Match(_BCL, MGE, Arg0, MTR, 0, 2), Local0)
                    If (LEqual(Local0, Ones)) { Subtract(SizeOf(_BCL), 1, Local0) }
                    Store(Or(DerefOf(Index(_BCL,Local0)),ShiftLeft(LMAX,16)), LEVX)
                }
                Method (_BQC, 0, NotSerialized)
                {
                    Store(Match(_BCL, MGE, And(LEVX, 0xFFFF), MTR, 0, 2), Local0)
                    If (LEqual(Local0, Ones)) { Subtract(SizeOf(_BCL), 1, Local0) }
                    Return(DerefOf(Index(_BCL, Local0)))
                }
                // extended _BCM/_BQC for setting "in between" levels
                Method (XBCM, 1, NotSerialized)
                {
                    // store new backlight level
                    If (LGreater(Arg0, XRGH)) { Store(XRGH, Arg0) }
                    If (LAnd(Arg0, LLess(Arg0, XRGL))) { Store(XRGL, Arg0) }
                    Store(Or(Arg0,ShiftLeft(LMAX,16)), LEVX)
                }
                Method (XBQC, 0, NotSerialized)
                {
                    Store(And(LEVX,0xFFFF), Local0)
                    If (LGreater(Local0, XRGH)) { Store(XRGH, Local0) }
                    If (LAnd(Local0, LLess(Local0, XRGL))) { Store(XRGL, Local0) }
                    Return(Local0)
                }
                // Set XOPT bit 0 to disable smooth transitions
                // Set XOPT bit 1 to wait for native BacklightHandler
                // Set XOPT bit 2 to force use of native BacklightHandler
                Name (XOPT, 0x02)
                // XRGL/XRGH: defines the valid range
                Name (XRGL, 25)
                Name (XRGH, 2777)
                // _BCL: returns list of valid brightness levels
                // first two entries describe ac/battery power levels
                Name (_BCL, Package()
                {
                    2777,
                    748,
                    0,
                    35, 39, 44, 50,
                    58, 67, 77, 88,
                    101, 115, 130, 147,
                    165, 184, 204, 226,
                    249, 273, 299, 326,
                    354, 383, 414, 446,
                    479, 514, 549, 587,
                    625, 665, 706, 748,
                    791, 836, 882, 930,
                    978, 1028, 1079, 1132,
                    1186, 1241, 1297, 1355,
                    1414, 1474, 1535, 1598,
                    1662, 1728, 1794, 1862,
                    1931, 2002, 2074, 2147,
                    2221, 2296, 2373, 2452,
                    2531, 2612, 2694, 2777,
                })
            }
        }
    }

    Scope (_SB)
    {
        Device (PCI0)
        {
            Device (LPCB)
            {
                Device (HPET)
                {
                    Name (_HID, EisaId ("PNP0103"))  // _HID: Hardware ID
                    Name (_UID, Zero)  // _UID: Unique ID
                    Name (BUF0, ResourceTemplate()
                    {
                        IRQNoFlags() { 0, 8, 11, 15 }

                        Memory32Fixed (ReadWrite,
                            0xFED00000,         // Address Base
                            0x00000400,         // Address Length
                            _Y0F)
                    })

                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If (LGreaterEqual (OSYS, 0x07D1))
                        {
                            If (HPAE)
                            {
                                Return (0x0F)
                            }
                        }
                        ElseIf (HPAE)
                        {
                            Return (0x0B)
                        }

                        Return (Zero)
                    }

                    Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                    {
                        If (HPAE)
                        {
                            CreateDWordField (BUF0, \_SB.PCI0.LPCB.HPET._Y0F._BAS, HPT0)  // _BAS: Base Address
                            If (LEqual (HPAS, One))
                            {
                                Store (0xFED01000, HPT0)
                            }

                            If (LEqual (HPAS, 0x02))
                            {
                                Store (0xFED02000, HPT0)
                            }

                            If (LEqual (HPAS, 0x03))
                            {
                                Store (0xFED03000, HPT0)
                            }
                        }

                        Return (BUF0)
                    }
                }
                
                Device (IPIC)
                {
                    Name (_HID, EisaId ("PNP0000"))  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0020,             // Range Minimum
                            0x0020,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0024,             // Range Minimum
                            0x0024,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0028,             // Range Minimum
                            0x0028,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x002C,             // Range Minimum
                            0x002C,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0030,             // Range Minimum
                            0x0030,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0034,             // Range Minimum
                            0x0034,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x0038,             // Range Minimum
                            0x0038,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x003C,             // Range Minimum
                            0x003C,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00A0,             // Range Minimum
                            0x00A0,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00A4,             // Range Minimum
                            0x00A4,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00A8,             // Range Minimum
                            0x00A8,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00AC,             // Range Minimum
                            0x00AC,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00B0,             // Range Minimum
                            0x00B0,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00B4,             // Range Minimum
                            0x00B4,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00B8,             // Range Minimum
                            0x00B8,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x00BC,             // Range Minimum
                            0x00BC,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        IO (Decode16,
                            0x04D0,             // Range Minimum
                            0x04D0,             // Range Maximum
                            0x01,               // Alignment
                            0x02,               // Length
                            )
                        
                    })
                }
                
                Device (RTC)
                {
                    Name (_HID, EisaId ("PNP0B00"))  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0070,             // Range Minimum
                            0x0070,             // Range Maximum
                            0x01,               // Alignment
                            0x08,               // Length
                            )
                        
                    })
                }
                
                Device (TIMR)
                {
                    Name (_HID, EisaId ("PNP0100"))  // _HID: Hardware ID
                    Name (_CRS, ResourceTemplate ()  // _CRS: Current Resource Settings
                    {
                        IO (Decode16,
                            0x0040,             // Range Minimum
                            0x0040,             // Range Maximum
                            0x01,               // Alignment
                            0x04,               // Length
                            )
                        IO (Decode16,
                            0x0050,             // Range Minimum
                            0x0050,             // Range Maximum
                            0x10,               // Alignment
                            0x04,               // Length
                            )
                        
                    })
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

                    Return (Package (0x02)
                    {
                        "compatible", 
                        "pci8086,9c43"
                    })
                }
            }
            
            Device (IMEI)
            {
                Name (_ADR, 0x00160000)
            }
            
            Device (MCHC)
            {
                Name (_ADR, Zero)
            }
        } 
    }
    
    Scope (_SB.PCI0)
    {
        Device (BUS0)
        {
            Name (_CID, "smbus")
            Name (_ADR, Zero)
            Device (DVL0)
            {
                Name (_ADR, 0x57)
                Name (_CID, "diagsvault")
                Method (_DSM, 4, NotSerialized)
                {
                    If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
                    Return (Package() { "address", 0x57 })
                }
            }
        }
    }
    
    Scope (\)
    {
        OperationRegion (RCRB, SystemMemory, SRCB, 0x4000)
        Field (RCRB, DWordAcc, Lock, Preserve)
        {
            HPAS,   2, 
            HPAE,   1, 
        }
    }

    Store ("SSDT-HDMI-HD4400 github.com/syscl/Inspiron15-5547", Debug)
}

