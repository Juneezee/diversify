<template>
  <div>
    <p>
      <strong>Ongoing Tasks:</strong> {{ count }}
    </p>
    <p v-if="moved">
      <strong>Recommendation:</strong> -
      <b-tooltip animated multilined label="Recompute to get Team Recommendation" position="is-top">
        <span class="iconify is-24" data-icon="twemoji:warning" />
      </b-tooltip>
    </p>
    <p v-else-if="recommendation.includes('Team')" class="compatibility-content">
      <strong>Recommendation:</strong> {{ recommendation }}
    </p>
    <p v-else-if="recommendation === ''">
      <strong>Recommendation:</strong> -
      <b-tooltip animated multilined label="No Recommendation can be made. This may be due to insufficient data or no compatible teams." position="is-top">
        <span class="iconify is-24" data-icon="twemoji:warning" />
      </b-tooltip>
    </p>
  </div>
</template>

<script>

export default {
  props: {
    count: {
      type: Number,
      required: true,
    },
    recommendation: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      moved: false,
    };
  },
  methods: {
    toggle(bool) {
      this.moved = bool;
    },
  },
};

</script>
