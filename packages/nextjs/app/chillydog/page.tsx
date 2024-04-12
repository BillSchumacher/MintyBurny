"use client";

import React, { useEffect, useState } from "react";
import Image from "next/image";
import type { NextPage } from "next";
import { formatEther } from "viem";
import { useAccount } from "wagmi";
import { useScaffoldContract, useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

const ChillyDog: NextPage = () => {
  // const [minted, setMinted] = useState(false);
  const [isMinting, setIsMinting] = useState(false);
  const { address: connectedAccount } = useAccount();

  // const { data: mintyBurnyRegistryContract } = useScaffoldContract({ contractName: "MintyBurnyRegistry" });
  const { data: chillyDogContract } = useScaffoldContract({ contractName: "ChillyDog" });
  // const { data: hotDogContract } = useScaffoldContract({ contractName: "HotDog" });
  const { data: hotDogTotalSupply } = useScaffoldContractRead({ contractName: "HotDog", functionName: "totalSupply" });
  const { data: mintFee } = useScaffoldContractRead({ contractName: "ChillyDog", functionName: "getMintFee" });
  const { data: lastMinted } = useScaffoldContractRead({ contractName: "ChillyDog", functionName: "lastMinted" });

  const { data: balanceOfChillyDog } = useScaffoldContractRead({
    contractName: "ChillyDog",
    functionName: "balanceOf",
    args: [connectedAccount],
  });

  const { data: yourMintTotal } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "mintedBy",
    args: [chillyDogContract?.address, connectedAccount],
  });

  const { data: yourBurnTotal } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "burnedFrom",
    args: [chillyDogContract?.address, connectedAccount],
  });

  const { data: totalMinters } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalMinters",
    args: [chillyDogContract?.address],
  });
  const { data: totalBurners } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalBurners",
    args: [chillyDogContract?.address],
  });

  const { data: totalMinted } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalMinted",
    args: [chillyDogContract?.address],
  });
  const { data: totalBurned } = useScaffoldContractRead({
    contractName: "MintyBurnyRegistry",
    functionName: "totalBurned",
    args: [chillyDogContract?.address],
  });
  const { writeAsync: doMint, isError: mintError } = useScaffoldContractWrite({
    contractName: "ChillyDog",
    functionName: "mintMinted",
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
          <b>Chilly Dog</b>
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
                    <b>Mintable:</b>{" "}
                    {hotDogTotalSupply && lastMinted ? Number(formatEther(hotDogTotalSupply - lastMinted)) : 0}
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
                      <b>Balance:</b> {balanceOfChillyDog ? Number(formatEther(balanceOfChillyDog)) : 0} chilly dogs
                    </div>
                    <br />
                    <div>
                      <u>Your Stats</u>
                    </div>
                    <div>
                      <b>Minted:</b> {yourMintTotal ? Number(formatEther(yourMintTotal)) : 0} chilly dogs
                    </div>
                    <div>
                      <b>Burned:</b> {yourBurnTotal ? Number(formatEther(yourBurnTotal)) : 0} chilly dogs
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
                      <b>Total Minted:</b> {totalMinted ? Number(formatEther(totalMinted)) : 0} chilly dogs
                    </div>
                    <div>
                      <b>Total Burned:</b> {totalBurned ? Number(formatEther(totalBurned)) : 0} chilly dogs
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div>
              <Image
                alt="Chilly Dog logo"
                className="cursor-pointer m-auto"
                width={420}
                height={420}
                src="/chilly_dog_logo.png"
              />
            </div>
          </div>
          <div className="flex flex-col items-center pt-4 max-lg:row-start-1">
            <div className="flex-grow bg-base-300 w-full mt-4 px-8 py-12">
              <p>The Chilly Dog (BRRRR) token is targeted at the Hot Dog (HOTDOG) token.</p>
              <p>
                When users mint Hot Dog (HOTDOG) tokens, 50% of the minted amount becomes mintable by the Chilly Dog
                (BRRRR) token.
              </p>
              <p>
                Anyone can initiate the minting process by calling the mint function on the Chilly Dog (BRRRR)
                token&apos;s smart contract.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChillyDog;
