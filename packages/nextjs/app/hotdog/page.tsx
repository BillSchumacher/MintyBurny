"use client";

import React, { useEffect, useState } from "react";
import Image from "next/image";
import type { NextPage } from "next";
import { formatEther } from "viem";
import { useAccount } from "wagmi";
import { useScaffoldContract, useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

const HotDog: NextPage = () => {
  // const [minted, setMinted] = useState(false);
  const [isMinting, setIsMinting] = useState(false);

  const { address: connectedAccount } = useAccount();

  const { data: hotDogContract } = useScaffoldContract({ contractName: "HotDog" });
  const { data: mintFee } = useScaffoldContractRead({ contractName: "HotDog", functionName: "getMintFee" });

  const { data: zAddressBalance } = useScaffoldContractRead({
    contractName: "Shib",
    functionName: "balanceOf",
    args: ["0x0000000000000000000000000000000000000000"],
  });
  const { data: dead1Address } = useScaffoldContractRead({
    contractName: "Shib",
    functionName: "balanceOf",
    args: ["0xdEAD000000000000000042069420694206942069"],
  });
  const { data: dead2Address } = useScaffoldContractRead({
    contractName: "Shib",
    functionName: "balanceOf",
    args: ["0x000000000000000000000000000000000000dEaD"],
  });
  const { data: lastBurned } = useScaffoldContractRead({ contractName: "HotDog", functionName: "lastBurned" });
  const { data: yourBurnTotal } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "burnedFrom",
    args: [hotDogContract?.address, connectedAccount],
  });

  const { data: yourMintTotal } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "mintedBy",
    args: [hotDogContract?.address, connectedAccount],
  });
  const { data: totalMinters } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalMinters",
    args: [hotDogContract?.address],
  });
  const { data: totalBurners } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalBurners",
    args: [hotDogContract?.address],
  });

  const { data: totalMinted } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalMinted",
    args: [hotDogContract?.address],
  });
  const { data: totalBurned } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalBurned",
    args: [hotDogContract?.address],
  });
  const { data: balanceOfHotDog } = useScaffoldContractRead({
    contractName: "HotDog",
    functionName: "balanceOf",
    args: [connectedAccount],
  });

  const { writeAsync: doMint, isError: mintError } = useScaffoldContractWrite({
    contractName: "HotDog",
    functionName: "mintBurned",
    gas: 1_000_000n,
    value: mintFee,
  });

  useEffect(() => {
    if (mintError) {
      setIsMinting(false);
      // setMinted(false);
    }
  }, [mintError]);

  return (
    <div className="py-10 px-10">
      <div className="flex flex-col items-center">
        <h1 className="text-3xl">
          <b>Hot Dog</b>
        </h1>
        <div className="grid grid-cols-2 max-lg:grid-cols-1 gap-10">
          <div className="w-full pt-8 max-lg:row-start-2 grid grid-cols-2 max-2xl:grid-cols-1 gap-5">
            <div className="flex flex-col w-full bg-base-100 px-10 py-10 text-center items-center rounded-3xl">
              <div className="grid grid-cols-1 max-lg:grid-cols-1 gap-10">
                <div className="min-w-max">
                  <div>
                    <b>Current Mint Fee:</b> Ξ{mintFee ? Number(formatEther(mintFee)) : 0}
                  </div>
                  <div>
                    <b>Mintable:</b>
                    {zAddressBalance !== undefined &&
                    dead1Address !== undefined &&
                    dead2Address !== undefined &&
                    lastBurned !== undefined
                      ? Number(
                          formatEther(
                            ((zAddressBalance + dead1Address + dead2Address - lastBurned) * BigInt(500)) / BigInt(1000),
                          ),
                        )
                      : 0}
                  </div>
                  <div className="flex">
                    <div className="m-auto">
                      <button
                        className="btn btn-secondary btn-lg "
                        onClick={() => {
                          setIsMinting(true);
                          doMint();
                        }}
                        disabled={isMinting}
                      >
                        <Image
                          alt="MintyBurny logo"
                          className="cursor-pointer"
                          width={42}
                          height={42}
                          src="/minty_burny_logo.png"
                        />
                        Mint
                      </button>
                    </div>
                  </div>
                  <div>
                    <br />
                    <div>
                      <b>Balance:</b> {balanceOfHotDog ? Number(formatEther(balanceOfHotDog)) : 0} hot dogs
                    </div>
                    <br />
                    <div>
                      <u>Your Stats</u>
                    </div>
                    <div>
                      <b>Minted:</b> {yourMintTotal ? Number(formatEther(yourMintTotal)) : 0} hot dogs
                    </div>
                    <div>
                      <b>Burned:</b> {yourBurnTotal ? Number(formatEther(yourBurnTotal)) : 0} hot dogs
                    </div>
                  </div>
                  <br />
                  <div>
                    <div>
                      <u>Overall Stats</u>
                    </div>
                    <div>
                      <b>Total Minters:</b> {totalMinters ? Number(totalMinters) : 0}
                    </div>
                    <div>
                      <b>Total Burners:</b> {totalBurners ? Number(totalBurners) : 0}
                    </div>
                    <div>
                      <b>Total Minted:</b> {totalMinted ? Number(formatEther(totalMinted)) : 0} hot dogs
                    </div>
                    <div>
                      <b>Total Burned:</b> {totalBurned ? Number(formatEther(totalBurned)) : 0} hot dogs
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div>
              <Image
                alt="Hotdog logo"
                className="cursor-pointer m-auto"
                width={420}
                height={420}
                src="/hotdog_logo.png"
              />
            </div>
          </div>

          <div className="flex flex-col items-center pt-4 max-lg:row-start-1">
            <div className="flex-grow bg-base-300 w-full mt-4 px-8 py-12">
              <p>
                The Hot Dog (HOTDOG) token uses a Proof-Of-Burn mechanism to mint tokens, while the Chilly Dog (BRRRR)
                token uses a Proof-Of-Mint mechanism to mint tokens.
              </p>

              <p>
                Hot Dog is targeted at the popular Shiba Inu token (SHIB)&apos;s 3 burn addresses that can be found on{" "}
                <a href="https://shibburn.com" className="underline italic">
                  https://shibburn.com
                </a>
                .
              </p>
              <p>
                Aside from demonstrating the Proof-Of-Burn and registry this may incentivise increased burning of SHIB.
              </p>

              <p>
                When SHIB tokens are burned (except to 0x address), 50% of the burnt amount becomes mintable by the Hot
                Dog (HOTDOG) token.
              </p>

              <p>
                Anyone can initiate the minting process by calling the mint function on the Hot Dog (HOTDOG)
                token&apos;s smart contract.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HotDog;
