"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-eth";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-4xl font-bold">Minty Burny</span>
          </h1>
          <div className="flex justify-center items-center space-x-2">
            <p className="my-2 font-medium">Connected Address:</p>
            <Address address={connectedAddress} />
          </div>
        </div>
        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <p>
            The Minty Burny registry is a smart contract that allows ERC20 tokens to track the amount of tokens minted
            and burned by an address.
          </p>

          <p>
            Implementation details can be found in the{" "}
            <a href="https://github.com/BillSchumacher/MintyBurny" target="_blank" className="underline italic">
              GitHub repository
            </a>
            , both Hot Dog (HOTDOG) and Chilly Dog (BRRRR) are ERC20 tokens that use the Minty Burny registry.
          </p>

          <p>
            The Hot Dog (HOTDOG) token uses a Proof-Of-Burn mechanism to mint tokens, while the Chilly Dog (BRRRR) token
            uses a Proof-Of-Mint mechanism to mint tokens.
          </p>

          <p>
            Hot Dog is targeted at the popular Shiba Inu token (SHIB)&apos;s 3 burn addresses that can be found on
            https://shibburn.com.
          </p>

          <p>Aside from demonstrating the Proof-Of-Burn and registry this may incentivise increased burning of SHIB.</p>

          <p>
            When SHIB tokens are burned, except for the 0x address, 50% of the burnt amount becomes mintable by the Hot
            Dog (HOTDOG) token.
          </p>
          <p>
            Anyone can initiate the minting process by calling the mint function on the Hot Dog (HOTDOG) token&apos;s
            smart contract.
          </p>

          <p>
            The Chilly Dog (BRRRR) token is targeted at the Hot Dog (HOTDOG) token, when users mint Hot Dog (HOTDOG)
            tokens, 50% of the minted amount becomes mintable by the Chilly Dog (BRRRR) token.
          </p>
          <p>
            Anyone can initiate the minting process by calling the mint function on the Chilly Dog (BRRRR) token&apos;s
            smart contract.
          </p>

          <p>
            A future contracts for AirDrops, Proof-Of-Minter and Proof-Of-Burner are planned as well. AirDrops will
            utilize the first/last minters/burners functions of the registry.
          </p>

          <p>
            A significant chunk of the initial tokens will be reserved for those AirDrops, some tokens are already
            available on UniSwap, the estimated amount one might get from a single mint.
          </p>

          <p>
            <a className="underline italic" href="https://app.uniswap.org/pools/702714">
              Hot Dog UniSwap Pool
            </a>
          </p>
          <p>
            {" "}
            <a className="underline italic" href="https://app.uniswap.org/pools/703584">
              Chilly Dog UniSwap Pool
            </a>
          </p>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <MagnifyingGlassIcon className="h-8 w-8 fill-secondary" />
              <p>
                Interact with the{" "}
                <Link href="/hotdog" passHref className="link">
                  Hot Dog (HOTDOG)
                </Link>{" "}
                tab.
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <MagnifyingGlassIcon className="h-8 w-8 fill-secondary" />
              <p>
                Interact with the{" "}
                <Link href="/chillydog" passHref className="link">
                  Chilly Dog (BRRRR)
                </Link>{" "}
                tab.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
