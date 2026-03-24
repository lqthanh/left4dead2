#if defined  _perkmod2_included_
 #endinput
#endif
#define _perkmod2_included_

native bool perkmod2_IsEnable_SurvivorPrimary();
native bool perkmod2_IsEnable_SurvivorPrimary_StoppingPower();
native bool perkmod2_IsEnable_SurvivorPrimary_SleightOfHand();
native bool perkmod2_IsEnable_SurvivorPrimary_Pyrotechnician();
native bool perkmod2_IsEnable_SurvivorPrimary_MartialArtist();
native bool perkmod2_IsEnable_SurvivorPrimary_ChristmasGift();

native bool perkmod2_IsEnable_SurvivorSecondary();
native bool perkmod2_IsEnable_SurvivorSecondary_Unbreakable();
native bool perkmod2_IsEnable_SurvivorSecondary_Spirit();
native bool perkmod2_IsEnable_SurvivorSecondary_HelpingHand();
native bool perkmod2_IsEnable_SurvivorSecondary_PackCat();

native bool perkmod2_IsEnable_SurvivorTertiary();
native bool perkmod2_IsEnable_SurvivorTertiary_PackRat();
native bool perkmod2_IsEnable_SurvivorTertiary_ChemReliant();
native bool perkmod2_IsEnable_SurvivorTertiary_HardToKill();
native bool perkmod2_IsEnable_SurvivorTertiary_ExtremeConditioning();

native bool perkmod2_IsClientConfirm(int client);
native bool perkmod2_IsClientSelect_SurvivorPrimary_StoppingPower(int client);
native bool perkmod2_IsClientSelect_SurvivorPrimary_SleightOfHand(int client);
native bool perkmod2_IsClientSelect_SurvivorPrimary_Pyrotechnician(int client);
native bool perkmod2_IsClientSelect_SurvivorPrimary_MartialArtist(int client);
native bool perkmod2_IsClientSelect_SurvivorPrimary_ChristmasGift(int client);
native bool perkmod2_IsClientSelect_SurvivorSecondary_Unbreakable(int client);
native bool perkmod2_IsClientSelect_SurvivorSecondary_Spirit(int client);
native bool perkmod2_IsClientSelect_SurvivorSecondary_HelpingHand(int client);
native bool perkmod2_IsClientSelect_SurvivorSecondary_PackCat(int client);
native bool perkmod2_IsClientSelect_SurvivorTertiary_PackRat(int client);
native bool perkmod2_IsClientSelect_SurvivorTertiary_ChemReliant(int client);
native bool perkmod2_IsClientSelect_SurvivorTertiary_HardToKill(int client);
native bool perkmod2_IsClientSelect_SurvivorTertiary_ExtremeConditioning(int client);

native bool perkmod2_IsExist_SurvivorPrimary_StoppingPower();
native bool perkmod2_IsExist_SurvivorPrimary_SleightOfHand();
native bool perkmod2_IsExist_SurvivorPrimary_Pyrotechnician();
native bool perkmod2_IsExist_SurvivorPrimary_MartialArtist();
native bool perkmod2_IsExist_SurvivorPrimary_ChristmasGift();
native bool perkmod2_IsExist_SurvivorSecondary_Unbreakable();
native bool perkmod2_IsExist_SurvivorSecondary_Spirit();
native bool perkmod2_IsExist_SurvivorSecondary_HelpingHand();
native bool perkmod2_IsExist_SurvivorSecondary_PackCat();
native bool perkmod2_IsExist_SurvivorTertiary_PackRat();
native bool perkmod2_IsExist_SurvivorTertiary_ChemReliant();
native bool perkmod2_IsExist_SurvivorTertiary_HardToKill();
native bool perkmod2_IsExist_SurvivorTertiary_ExtremeConditioning();

native int perkmod2_Pyro_OnWeaponFire(int client, char[] weapon);
