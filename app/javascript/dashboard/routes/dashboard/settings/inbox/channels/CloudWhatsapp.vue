<template>
  <form class="mx-0 flex flex-wrap" @submit.prevent="createChannel()">
    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.inboxName.$error }">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.LABEL') }}
        <input
          v-model.trim="inboxName"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.PLACEHOLDER')"
          @blur="$v.inboxName.$touch"
        />
        <span v-if="$v.inboxName.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.INBOX_NAME.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.phoneNumber.$error }">
        {{ $t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER.LABEL') }}
        <input
          v-model.trim="phoneNumber"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER.PLACEHOLDER')"
          @blur="$v.phoneNumber.$touch"
        />
        <span v-if="$v.phoneNumber.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.phoneNumberId.$error }">
        <span>
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER_ID.LABEL') }}
        </span>
        <input
          v-model.trim="phoneNumberId"
          type="text"
          :placeholder="
            $t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER_ID.PLACEHOLDER')
          "
          @blur="$v.phoneNumberId.$touch"
        />
        <span v-if="$v.phoneNumberId.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.PHONE_NUMBER_ID.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.businessAccountId.$error }">
        <span>
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.BUSINESS_ACCOUNT_ID.LABEL') }}
        </span>
        <input
          v-model.trim="businessAccountId"
          type="text"
          :placeholder="
            $t('INBOX_MGMT.ADD.WHATSAPP.BUSINESS_ACCOUNT_ID.PLACEHOLDER')
          "
          @blur="$v.businessAccountId.$touch"
        />
        <span v-if="$v.businessAccountId.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.BUSINESS_ACCOUNT_ID.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label :class="{ error: $v.apiKey.$error }">
        <span>
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.API_KEY.LABEL') }}
        </span>
        <input
          v-model.trim="apiKey"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.WHATSAPP.API_KEY.PLACEHOLDER')"
          @blur="$v.apiKey.$touch"
        />
        <span v-if="$v.apiKey.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.WHATSAPP.API_KEY.ERROR') }}
        </span>
      </label>
    </div>

    <div class="w-full">
      <woot-submit-button
        :loading="uiFlags.isCreating"
        :button-text="$t('INBOX_MGMT.ADD.WHATSAPP.SUBMIT_BUTTON')"
      />
    </div>
  </form>
</template>

<script>
import { mapGetters } from 'vuex';
import alertMixin from 'shared/mixins/alertMixin';
import { required } from 'vuelidate/lib/validators';
import router from '../../../../index';
import { isPhoneE164OrEmpty, isNumber } from 'shared/helpers/Validators';

export default {
  mixins: [alertMixin],
  data() {
    return {
      inboxName: '',
      phoneNumber: '',
      apiKey: '',
      phoneNumberId: '',
      businessAccountId: '',
      advanced: false,
    };
  },
  computed: {
    ...mapGetters({ uiFlags: 'inboxes/getUIFlags' }),
  },
  validations: {
    inboxName: { required },
    phoneNumber: { required, isPhoneE164OrEmpty },
    apiKey: { required },
    phoneNumberId: { required, isNumber },
    businessAccountId: { required, isNumber },
    url: { required },
  },
  methods: {
    async createChannel() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }

      try {
        const whatsappChannel = await this.$store.dispatch(
          'inboxes/createChannel',
          {
            name: this.inboxName,
            channel: {
              type: 'whatsapp',
              phone_number: this.phoneNumber,
              provider: 'whatsapp_cloud',
              provider_config: {
                api_key: this.apiKey,
                phone_number_id: this.phoneNumberId,
                business_account_id: this.businessAccountId,
              },
            },
          }
        );

        router.replace({
          name: 'settings_inboxes_add_agents',
          params: {
            page: 'new',
            inbox_id: whatsappChannel.id,
          },
        });
      } catch (error) {
        this.showAlert(
          this.$t('INBOX_MGMT.ADD.WHATSAPP.API.ERROR_MESSAGE') +
            '\n detail:' +
            error
        );
      }
    },
  },
};
</script>
